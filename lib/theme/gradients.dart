import 'package:flutter/cupertino.dart';

/// Central place for the gradient palette so every screen looks consistent.
class AppGradients {
  AppGradients._();

  /// Full-screen background gradient (deep space -> violet -> magenta).
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B0B1E),
      Color(0xFF241B4E),
      Color(0xFF3B1E63),
      Color(0xFF120B2B),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  /// Accent gradient used on the play button / active states / progress.
  static const LinearGradient accent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF5FA2), Color(0xFF7C5CFF), Color(0xFF35C4FF)],
  );

  /// Gradient for song artwork placeholders (varies per index for variety).
  static LinearGradient artworkFor(int index) {
    final palettes = <List<Color>>[
      [const Color(0xFFFF7A7A), const Color(0xFF7C5CFF)],
      [const Color(0xFF35C4FF), const Color(0xFF7C5CFF)],
      [const Color(0xFFFFC371), const Color(0xFFFF5F6D)],
      [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      [const Color(0xFFFA8BFF), const Color(0xFF2BD2FF)],
    ];
    final p = palettes[index % palettes.length];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: p,
    );
  }

  /// Subtle glass tint overlaid on top of BackdropFilter blur.
  static LinearGradient glassTint({double opacity = 0.14}) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      CupertinoColors.white.withOpacity(opacity + 0.06),
      CupertinoColors.white.withOpacity(opacity * 0.4),
    ],
  );
}
