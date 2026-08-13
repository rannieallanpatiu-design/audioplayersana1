import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/song_tile.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final playlists =
    ref.watch(playlistControllerProvider);
    final playback = ref.watch(audioControllerProvider);

    final bundled = library
        .where((s) => s.source == SongSource.asset)
        .toList();

    final imported = library
        .where((s) => s.source == SongSource.file)
        .toList();

    return ListView(
      padding: const EdgeInsets.only(
        top: 24,
        bottom: 160,
      ),
      children: [
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Library',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () async {
                  final count = await ref
                      .read(libraryProvider.notifier)
                      .importFromDevice();

                  if (context.mounted && count > 0) {
                    _toast(
                      context,
                      'Imported $count song${count == 1 ? '' : 's'}',
                    );
                  }
                },
                child: const Icon(
                  CupertinoIcons.folder_badge_plus,
                  color: CupertinoColors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _SectionHeader(
          title: 'Playlists',
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () =>
                _createPlaylist(context, ref),
            child: const Icon(
              CupertinoIcons.add_circled,
              color: Color(0xFFFF5FA2),
              size: 24,
            ),
          ),
        ),

        if (playlists.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Text(
              'No playlists yet. Tap + to create one.',
              style: TextStyle(
                color:
                CupertinoColors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          )
        else
          ...playlists.map(
                (playlist) {
              final songs = ref
                  .read(playlistControllerProvider.notifier)
                  .songsForPlaylist(
                playlist,
                library,
              );

              return _PlaylistTile(
                playlist: playlist,
                songCount: songs.length,
                onPlay: songs.isEmpty
                    ? null
                    : () {
                  ref
                      .read(
                    audioControllerProvider
                        .notifier,
                  )
                      .playQueue(songs, 0);
                },
                onTap: () => _openPlaylist(
                  context,
                  ref,
                  playlist,
                ),
                onDelete: () async {
                  await ref
                      .read(
                    playlistControllerProvider
                        .notifier,
                  )
                      .deletePlaylist(playlist.id);
                },
              );
            },
          ),

        const SizedBox(height: 20),

        _SectionHeader(
          title: 'Bundled (${bundled.length})',
        ),

        ...bundled.asMap().entries.map(
              (entry) {
            return SongTile(
              song: entry.value,
              index: entry.key,
              isActive:
              playback.currentSong?.id ==
                  entry.value.id,
              onTap: () {
                ref
                    .read(
                  audioControllerProvider
                      .notifier,
                )
                    .playQueue(
                  bundled,
                  entry.key,
                );
              },
            );
          },
        ),

        const SizedBox(height: 12),

        _SectionHeader(
          title:
          'Imported from device (${imported.length})',
        ),

        if (imported.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Text(
              'Tap the folder icon above to add songs from your phone.',
              style: TextStyle(
                color:
                CupertinoColors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          )
        else
          ...imported.asMap().entries.map(
                (entry) {
              final song = entry.value;

              return Dismissible(
                key: ValueKey(song.id),
                direction:
                DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding:
                  const EdgeInsets.only(right: 28),
                  child: const Icon(
                    CupertinoIcons.delete,
                    color: CupertinoColors
                        .destructiveRed,
                  ),
                ),
                onDismissed: (_) {
                  ref
                      .read(
                    libraryProvider.notifier,
                  )
                      .removeSong(song.id);
                },
                child: SongTile(
                  song: song,
                  index: entry.key,
                  isActive:
                  playback.currentSong?.id ==
                      song.id,
                  onTap: () {
                    ref
                        .read(
                      audioControllerProvider
                          .notifier,
                    )
                        .playQueue(
                      imported,
                      entry.key,
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  void _createPlaylist(
      BuildContext context,
      WidgetRef ref,
      ) {
    final controller = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Create Playlist'),
          content: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: CupertinoTextField(
              controller: controller,
              autofocus: true,
              placeholder: 'Playlist name',
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                controller.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                final name =
                controller.text.trim();

                if (name.isEmpty) return;

                await ref
                    .read(
                  playlistControllerProvider
                      .notifier,
                )
                    .createPlaylist(name);

                controller.dispose();

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _openPlaylist(
      BuildContext context,
      WidgetRef ref,
      MusicPlaylist playlist,
      ) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => PlaylistDetailScreen(
          playlist: playlist,
        ),
      ),
    );
  }

  void _toast(
      BuildContext context,
      String message,
      ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          message: Text(message),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class PlaylistDetailScreen
    extends ConsumerWidget {
  final MusicPlaylist playlist;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final library = ref.watch(libraryProvider);

    final currentPlaylist = ref
        .watch(playlistControllerProvider)
        .firstWhere(
          (p) => p.id == playlist.id,
      orElse: () => playlist,
    );

    final songs = ref
        .read(playlistControllerProvider.notifier)
        .songsForPlaylist(
      currentPlaylist,
      library,
    );

    final playback =
    ref.watch(audioControllerProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(currentPlaylist.name),
      ),
      child: SafeArea(
        child: ListView(
          padding:
          const EdgeInsets.only(bottom: 40),
          children: [
            const SizedBox(height: 24),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: SizedBox(
                height: 52,
                child: CupertinoButton.filled(
                  borderRadius:
                  BorderRadius.circular(18),
                  onPressed: songs.isEmpty
                      ? null
                      : () {
                    ref
                        .read(
                      audioControllerProvider
                          .notifier,
                    )
                        .playQueue(
                      songs,
                      0,
                    );
                  },
                  child: const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.play_fill,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text('Play Playlist'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Text(
                '${songs.length} song${songs.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color:
                  CupertinoColors.white
                      .withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 8),

            if (songs.isEmpty)
              Padding(
                padding:
                const EdgeInsets.all(20),
                child: Text(
                  'This playlist is empty.\nUse the ••• button on a song to add it.',
                  style: TextStyle(
                    color:
                    CupertinoColors.white
                        .withOpacity(0.5),
                  ),
                ),
              )
            else
              ...songs.asMap().entries.map(
                    (entry) {
                  final song = entry.value;

                  return Dismissible(
                    key: ValueKey(
                      '${currentPlaylist.id}_${song.id}',
                    ),
                    direction:
                    DismissDirection.endToStart,
                    background: Container(
                      alignment:
                      Alignment.centerRight,
                      padding:
                      const EdgeInsets.only(
                        right: 28,
                      ),
                      child: const Icon(
                        CupertinoIcons.delete,
                        color: CupertinoColors
                            .destructiveRed,
                      ),
                    ),
                    onDismissed: (_) {
                      ref
                          .read(
                        playlistControllerProvider
                            .notifier,
                      )
                          .removeSongFromPlaylist(
                        currentPlaylist.id,
                        song.id,
                      );
                    },
                    child: SongTile(
                      song: song,
                      index: entry.key,
                      isActive:
                      playback.currentSong
                          ?.id ==
                          song.id,
                      onTap: () {
                        ref
                            .read(
                          audioControllerProvider
                              .notifier,
                        )
                            .playQueue(
                          songs,
                          entry.key,
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final MusicPlaylist playlist;
  final int songCount;
  final VoidCallback? onPlay;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PlaylistTile({
    required this.playlist,
    required this.songCount,
    required this.onPlay,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin:
        const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: CupertinoColors.white
              .withOpacity(0.06),
          borderRadius:
          BorderRadius.circular(18),
          border: Border.all(
            color: CupertinoColors.white
                .withOpacity(0.08),
          ),
        ),
        child: CupertinoButton(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          onPressed: onTap,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF5FA2),
                      Color(0xFF6C63FF),
                    ],
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.music_note_list,
                  color:
                  CupertinoColors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                        CupertinoColors.white,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$songCount song${songCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        color:
                        CupertinoColors.white
                            .withOpacity(0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 36,
                onPressed: onPlay,
                child: Icon(
                  CupertinoIcons.play_circle_fill,
                  color: onPlay == null
                      ? CupertinoColors.white
                      .withOpacity(0.2)
                      : const Color(
                    0xFFFF5FA2,
                  ),
                  size: 30,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 36,
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (_) {
                      return CupertinoActionSheet(
                        title:
                        Text(playlist.name),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(
                                context,
                              );
                              onDelete();
                            },
                            isDestructiveAction:
                            true,
                            child:
                            const Text(
                              'Delete Playlist',
                            ),
                          ),
                        ],
                        cancelButton:
                        CupertinoActionSheetAction(
                          onPressed: () =>
                              Navigator.pop(
                                context,
                              ),
                          child:
                          const Text(
                            'Cancel',
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Icon(
                  CupertinoIcons.ellipsis,
                  color:
                  CupertinoColors.white
                      .withOpacity(0.5),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: CupertinoColors.white
                    .withOpacity(0.7),
                fontSize: 14,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}