import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);
    final playback = ref.watch(audioControllerProvider);

    return ListView(
      padding: const EdgeInsets.only(top: 24, bottom: 160),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            query.isEmpty ? 'All songs' : 'Results for "$query"',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Text(
              'No songs found.',
              style: TextStyle(color: CupertinoColors.white.withOpacity(0.6)),
            ),
          )
        else
          ...results.asMap().entries.map(
                (entry) => SongTile(
              song: entry.value,
              index: entry.key,
              isActive: playback.currentSong?.id == entry.value.id,
              onTap: () =>
                  ref.read(audioControllerProvider.notifier).playQueue(results, entry.key),
            ),
          ),
      ],
    );
  }
}
