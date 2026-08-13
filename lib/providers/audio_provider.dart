import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import 'library_provider.dart';

class PlaybackState {
  final Song? currentSong;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final List<Song> queue;
  final int queueIndex;

  const PlaybackState({
    this.currentSong,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.queue = const [],
    this.queueIndex = -1,
  });

  double get progress =>
      duration.inMilliseconds == 0 ? 0 : position.inMilliseconds / duration.inMilliseconds;

  PlaybackState copyWith({
    Song? currentSong,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    List<Song>? queue,
    int? queueIndex,
  }) {
    return PlaybackState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
    );
  }
}

/// Drives playback via [PlayerAudioService] (audioplayers) and exposes a
/// single reactive [PlaybackState] to the whole widget tree.
class AudioController extends StateNotifier<PlaybackState> {
  AudioController() : super(const PlaybackState()) {
    _bindStreams();
  }

  final PlayerAudioService _service = PlayerAudioService();

  void _bindStreams() {
    _service.onPositionChanged.listen((pos) {
      state = state.copyWith(position: pos);
    });
    _service.onDurationChanged.listen((dur) {
      state = state.copyWith(duration: dur, isBuffering: false);
    });
    _service.onStateChanged.listen((playerState) {
      state = state.copyWith(isPlaying: playerState == PlayerState.playing);
    });
    _service.onComplete.listen((_) => next());
  }

  Future<void> playQueue(List<Song> queue, int startIndex) async {
    state = state.copyWith(queue: queue, queueIndex: startIndex, isBuffering: true);
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    if (state.queueIndex < 0 || state.queueIndex >= state.queue.length) return;
    final song = state.queue[state.queueIndex];
    state = state.copyWith(currentSong: song, isBuffering: true, position: Duration.zero);
    try {
      await _service.play(song);
    } catch (_) {
      // Missing/corrupt file (e.g. placeholder asset not yet added) —
      // stop buffering so the UI doesn't hang, keep the song "selected".
      state = state.copyWith(isBuffering: false, isPlaying: false);
    }
  }

  Future<void> togglePlayPause() async {
    if (state.currentSong == null) return;
    if (state.isPlaying) {
      await _service.pause();
    } else {
      await _service.resume();
    }
  }

  Future<void> next() async {
    if (state.queue.isEmpty) return;
    final nextIndex = (state.queueIndex + 1) % state.queue.length;
    state = state.copyWith(queueIndex: nextIndex);
    await _playCurrent();
  }

  Future<void> previous() async {
    if (state.queue.isEmpty) return;
    final prevIndex = (state.queueIndex - 1 + state.queue.length) % state.queue.length;
    state = state.copyWith(queueIndex: prevIndex);
    await _playCurrent();
  }

  Future<void> seek(Duration position) => _service.seek(position);

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

final audioControllerProvider =
StateNotifierProvider<AudioController, PlaybackState>((ref) => AudioController());

/// Convenience: play a single song as a 1-item queue, or start the whole
/// library from a tapped index.
final playSongFromLibraryProvider = Provider((ref) {
  return (int index) {
    final library = ref.read(libraryProvider);
    ref.read(audioControllerProvider.notifier).playQueue(library, index);
  };
});

