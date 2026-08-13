import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';

/// Thin wrapper around [AudioPlayer] from the `audioplayers` package.
///
/// Handles both:
/// - bundled assets (assets/audio/*.mp3) -> [AssetSource]
/// - user-imported files on device storage -> [DeviceFileSource]
///
/// Configured with [PlayerMode.mediaPlayer] on Android for music playback.
class PlayerAudioService {
  PlayerAudioService() {
    _player.setPlayerMode(PlayerMode.mediaPlayer);
    _player.setReleaseMode(ReleaseMode.stop);

    _player.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
        ),
      ),
    );
  }

  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get raw => _player;

  Stream<Duration> get onPositionChanged =>
      _player.onPositionChanged;

  Stream<Duration> get onDurationChanged =>
      _player.onDurationChanged;

  Stream<void> get onComplete =>
      _player.onPlayerComplete;

  Stream<PlayerState> get onStateChanged =>
      _player.onPlayerStateChanged;

  Future<void> play(Song song) async {
    final source = song.source == SongSource.asset
        ? AssetSource(
      song.path.replaceFirst('assets/', ''),
    )
        : DeviceFileSource(song.path);

    await _player.play(source);
  }

  Future<void> pause() => _player.pause();

  Future<void> resume() => _player.resume();

  Future<void> stop() => _player.stop();

  Future<void> seek(Duration position) =>
      _player.seek(position);

  Future<void> setVolume(double volume) =>
      _player.setVolume(volume);

  Future<void> dispose() =>
      _player.dispose();
}