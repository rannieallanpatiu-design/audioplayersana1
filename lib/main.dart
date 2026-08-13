import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-warms the liquid glass shaders so there's no white flash / GLES
  // compile jank on the first frame (see liquid_glass_widgets docs).
  await LiquidGlassWidgets.initialize();

  runApp(
    ProviderScope(
      child: LiquidGlassWidgets.wrap(
        // Auto-benchmarks the device and steps quality up/down so the
        // glass effect stays smooth on lower-end phones too.
        adaptiveQuality: true,
        child: const LiquidMusicApp(),
      ),
    ),
  );
}
