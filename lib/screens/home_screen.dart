import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../providers/scroll_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/liquid_glass_tab_bar.dart';
import '../widgets/mini_player_pill.dart';
import '../widgets/song_tile.dart';
import 'library_screen.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _tabBarKey = GlobalKey();
  GlassTab _tab = GlassTab.home;

  static const double _tabBarTotalHeight = 64 + 16; // bar height + bottom padding

  @override
  void initState() {
    super.initState();
    // Requirement: once offset > 50 the pill docks between the home &
    // search icons. We only push updates when the boolean actually flips
    // to avoid rebuilding on every scroll pixel.
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      final wasDocked = ref.read(pillDockedProvider);
      ref.read(scrollOffsetProvider.notifier).state = offset;
      final isDocked = offset > kPillDockThreshold;
      if (isDocked != wasDocked) {
        // pillDockedProvider recomputes automatically from scrollOffsetProvider.
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);
    final playback = ref.watch(audioControllerProvider);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0B0B1E),
      child: GradientBackground(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: _tab == GlassTab.library
                  ? const LibraryScreen()
                  : _tab == GlassTab.search
                  ? const SearchScreen()
                  : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Good evening',
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
                              final count =
                              await ref.read(libraryProvider.notifier).importFromDevice();
                              if (context.mounted && count > 0) {
                                _showImportedSheet(context, count);
                              }
                            },
                            child: const Icon(CupertinoIcons.add_circled,
                                color: CupertinoColors.white, size: 28),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Text(
                        'Your Library',
                        style: TextStyle(
                          color: CupertinoColors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: library.length,
                    itemBuilder: (context, index) {
                      final song = library[index];
                      return SongTile(
                        song: song,
                        index: index,
                        isActive: playback.currentSong?.id == song.id,
                        onTap: () => ref
                            .read(audioControllerProvider.notifier)
                            .playQueue(library, index),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 160)),
                ],
              ),
            ),
            // Mini player pill floats above everything, repositioning via
            // AnimatedPositioned as the user scrolls (see MiniPlayerPill).
            MiniPlayerPill(tabBarHeight: _tabBarTotalHeight),
            Align(
              alignment: Alignment.bottomCenter,
              child: LiquidGlassTabBar(
                barKey: _tabBarKey,
                current: _tab,
                onTabSelected: (tab) => setState(() => _tab = tab),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportedSheet(BuildContext context, int count) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Imported $count song${count == 1 ? '' : 's'}'),
        message: const Text('Added to your library.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
