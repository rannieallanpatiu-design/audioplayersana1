import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/audio_provider.dart';
import '../providers/scroll_provider.dart';
import '../screens/now_playing_screen.dart';
import '../theme/gradients.dart';

class MiniPlayerPill extends ConsumerWidget {
  final double tabBarHeight;

  const MiniPlayerPill({
    super.key,
    required this.tabBarHeight,
  });

  static const double _dockedSize = 46;
  static const double _expandedHeight = 72;
  static const double _sideInset = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(audioControllerProvider);
    final docked = ref.watch(pillDockedProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    if (playback.currentSong == null) {
      return const SizedBox.shrink();
    }

    final barContentWidth =
        screenWidth - (_sideInset * 2);

    final dockedCenterX =
        _sideInset + (barContentWidth * (1 / 3));

    final left = docked
        ? dockedCenterX - (_dockedSize / 2)
        : _sideInset;

    final right = docked
        ? screenWidth -
        dockedCenterX -
        (_dockedSize / 2)
        : _sideInset;

    final bottom = docked
        ? (tabBarHeight - _dockedSize) / 2 + 16
        : tabBarHeight + 8;

    final height =
    docked ? _dockedSize : _expandedHeight;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      left: left,
      right: right,
      bottom: bottom,
      height: height,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const NowPlayingScreen(),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            docked ? _dockedSize : 24,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 24,
              sigmaY: 24,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: AppGradients.accent,
                borderRadius: BorderRadius.circular(
                  docked ? _dockedSize : 24,
                ),
                border: Border.all(
                  color: CupertinoColors.white
                      .withOpacity(0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black
                        .withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: docked
                  ? _DockedContent(
                playback: playback,
                ref: ref,
              )
                  : _ExpandedContent(
                playback: playback,
                ref: ref,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockedContent extends StatelessWidget {
  final PlaybackState playback;
  final WidgetRef ref;

  const _DockedContent({
    required this.playback,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        ref
            .read(audioControllerProvider.notifier)
            .togglePlayPause();
      },
      child: Icon(
        playback.isPlaying
            ? CupertinoIcons.pause_fill
            : CupertinoIcons.play_fill,
        color: CupertinoColors.white,
        size: 20,
      ),
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  final PlaybackState playback;
  final WidgetRef ref;

  const _ExpandedContent({
    required this.playback,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final song = playback.currentSong!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient:
              AppGradients.artworkFor(song.id.hashCode),
            ),
            child: const Icon(
              CupertinoIcons.music_note,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CupertinoColors.white
                        .withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () {
              ref
                  .read(audioControllerProvider.notifier)
                  .togglePlayPause();
            },
            child: Icon(
              playback.isPlaying
                  ? CupertinoIcons.pause_fill
                  : CupertinoIcons.play_fill,
              color: CupertinoColors.white,
              size: 25,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () {
              ref
                  .read(audioControllerProvider.notifier)
                  .next();
            },
            child: const Icon(
              CupertinoIcons.forward_fill,
              color: CupertinoColors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}