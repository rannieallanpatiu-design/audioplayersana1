import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../theme/gradients.dart';
import '../widgets/gradient_background.dart';

class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(audioControllerProvider);
    final song = playback.currentSong;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0B0B1E),
      child: GradientBackground(
        child: SafeArea(
          child: song == null
              ? const Center(
            child: Text('Nothing playing', style: TextStyle(color: CupertinoColors.white)),
          )
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.chevron_down, color: CupertinoColors.white),
                  ),
                ),
                const Spacer(),
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      decoration:
                      BoxDecoration(gradient: AppGradients.artworkFor(song.id.hashCode)),
                      child: const Icon(CupertinoIcons.music_note_2,
                          color: CupertinoColors.white, size: 72),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  song.title,
                  style: const TextStyle(
                      color: CupertinoColors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  song.artist,
                  style: TextStyle(color: CupertinoColors.white.withOpacity(0.6), fontSize: 15),
                ),
                const SizedBox(height: 28),
                CupertinoSlider(
                  value: playback.duration.inMilliseconds == 0
                      ? 0
                      : playback.position.inMilliseconds
                      .clamp(0, playback.duration.inMilliseconds)
                      .toDouble(),
                  min: 0,
                  max: playback.duration.inMilliseconds == 0
                      ? 1
                      : playback.duration.inMilliseconds.toDouble(),
                  activeColor: const Color(0xFFFF5FA2),
                  onChanged: (value) => ref
                      .read(audioControllerProvider.notifier)
                      .seek(Duration(milliseconds: value.toInt())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(playback.position),
                          style: TextStyle(color: CupertinoColors.white.withOpacity(0.6), fontSize: 12)),
                      Text(_fmt(playback.duration),
                          style: TextStyle(color: CupertinoColors.white.withOpacity(0.6), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CupertinoButton(
                      onPressed: () => ref.read(audioControllerProvider.notifier).previous(),
                      child: const Icon(CupertinoIcons.backward_fill,
                          color: CupertinoColors.white, size: 34),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(audioControllerProvider.notifier).togglePlayPause(),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                            gradient: AppGradients.accent, shape: BoxShape.circle),
                        child: Icon(
                          playback.isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                          color: CupertinoColors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => ref.read(audioControllerProvider.notifier).next(),
                      child: const Icon(CupertinoIcons.forward_fill,
                          color: CupertinoColors.white, size: 34),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
