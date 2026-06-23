import 'package:flutter/material.dart';

class AppColors {
  // Swiss minimal palette
  static const Color primary = Color(0xFF0057FF);
  static const Color primaryLight = Color(0xFF4F86FF);
  static const Color primaryDark = Color(0xFF0038A8);
  static const Color primarySurface = Color(0xFFEAF0FF);
  static const Color primaryBorder = Color(0xFFB8C9FF);

  // Semantic
  static const Color green = Color(0xFF087A4A);
  static const Color greenSurface = Color(0xFFEAF6F0);
  static const Color amber = Color(0xFFC76F00);
  static const Color amberSurface = Color(0xFFFFF3DF);
  static const Color red = Color(0xFFD42121);
  static const Color redSurface = Color(0xFFFFEDED);
  static const Color violet = Color(0xFF5D45D6);
  static const Color violetSurface = Color(0xFFF0EEFF);

  // Neutral
  static const Color ink = Color(0xFF111111);
  static const Color slate600 = Color(0xFF3E3E3E);
  static const Color slate500 = Color(0xFF666666);
  static const Color slate400 = Color(0xFF8A8A8A);
  static const Color slate300 = Color(0xFFCFCFCF);
  static const Color line = Color(0xFFE0E0E0);
  static const Color line2 = Color(0xFFEDEDED);
  static const Color bg = Color(0xFFF7F7F4);
  static const Color white = Color(0xFFFFFFFF);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    colors: [primary, primaryDark],
  );

  // Shadows
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 10,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];
  static const List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];
  static const List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: Color(0x220057FF),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  // Tone map for FeatureIcon
  static Map<String, List<Color>> tones = {
    'blue': [primarySurface, primary],
    'green': [greenSurface, green],
    'amber': [amberSurface, amber],
    'red': [redSurface, red],
    'violet': [violetSurface, violet],
    'slate': [bg, slate600],
  };

  static List<Color> tone(String name) => tones[name] ?? tones['blue']!;
}
