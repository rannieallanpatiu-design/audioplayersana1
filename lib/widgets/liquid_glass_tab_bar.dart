import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import '../providers/library_provider.dart';

/// App navigation tabs.
///
/// This enum is intentionally named AppTab because the
/// liquid_glass_widgets package also provides its own GlassTab class.
enum GlassTab {
  home,
  search,
  library,
}

class LiquidGlassTabBar extends ConsumerStatefulWidget {
  final GlassTab current;
  final ValueChanged<GlassTab> onTabSelected;
  final GlobalKey barKey;

  const LiquidGlassTabBar({
    super.key,
    required this.current,
    required this.onTabSelected,
    required this.barKey,
  });

  @override
  ConsumerState<LiquidGlassTabBar> createState() =>
      _LiquidGlassTabBarState();
}

class _LiquidGlassTabBarState
    extends ConsumerState<LiquidGlassTabBar> {
  bool _searchExpanded = false;

  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() {
      _searchExpanded = true;
    });

    widget.onTabSelected(GlassTab.search);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _searchFocus.requestFocus();
      }
    });
  }

  void _closeSearch() {
    _searchFocus.unfocus();

    ref.read(searchQueryProvider.notifier).state = '';

    setState(() {
      _searchExpanded = false;
    });

    widget.onTabSelected(GlassTab.home);
  }

  @override
  Widget build(BuildContext context) {
    if (_searchExpanded) {
      return _buildSearchBar();
    }

    final selectedIndex = switch (widget.current) {
      GlassTab.home => 0,
      GlassTab.search => 1,
      GlassTab.library => 2,
    };

    return Padding(
      key: widget.barKey,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: lg.GlassTabBar.bottom(
        tabs: const [
          lg.GlassTab(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          lg.GlassTab(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          lg.GlassTab(
            icon: Icon(CupertinoIcons.music_albums_fill),
            label: 'Library',
          ),
        ],
        selectedIndex: selectedIndex,
        onTabSelected: (index) {
          switch (index) {
            case 0:
              widget.onTabSelected(GlassTab.home);
              break;

            case 1:
              _openSearch();
              break;

            case 2:
              widget.onTabSelected(GlassTab.library);
              break;
          }
        },

        // Liquid Glass appearance
        barHeight: 64,
        barBorderRadius: 30,
        horizontalPadding: 4,
        verticalPadding: 0,
        spacing: 8,
        iconLabelSpacing: 4,

        // iOS-style liquid glass interaction
        enableBlend: true,
        blendAmount: 10,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      key: widget.barKey,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        height: 64,
        child: lg.GlassCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.search,
                  color: CupertinoColors.white,
                  size: 20,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: CupertinoTextField(
                    focusNode: _searchFocus,
                    placeholder: 'Search songs or artists',
                    placeholderStyle: TextStyle(
                      color: CupertinoColors.white.withOpacity(0.5),
                    ),
                    style: const TextStyle(
                      color: CupertinoColors.white,
                    ),
                    decoration: const BoxDecoration(
                      color: CupertinoColors.transparent,
                    ),
                    onChanged: (value) {
                      ref
                          .read(searchQueryProvider.notifier)
                          .state = value;
                    },
                  ),
                ),

                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: _closeSearch,
                  child: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: CupertinoColors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}