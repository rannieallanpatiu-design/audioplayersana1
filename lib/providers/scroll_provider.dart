import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raw scroll offset of the home list, updated by the screen's
/// ScrollController listener. Widgets (like the mini player pill) watch
/// [pillDockedProvider] instead of this directly to avoid rebuilding on
/// every pixel — it only flips when crossing the 50px threshold.
final scrollOffsetProvider = StateProvider<double>((ref) => 0);

const double kPillDockThreshold = 50;

/// True once the user has scrolled past 50px -> the pill should dock
/// itself between the home & search icons in the glass tab bar.
final pillDockedProvider = Provider<bool>((ref) {
  final offset = ref.watch(scrollOffsetProvider);
  return offset > kPillDockThreshold;
});
