import 'package:flutter/material.dart';

/// iOS System palette 기반.
/// https://developer.apple.com/design/human-interface-guidelines/color
class IosPalette {
  IosPalette._();

  // System Blue — primary accent
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemBlueDark = Color(0xFF0A84FF);

  // Semantic
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemOrange = Color(0xFFFF9500);

  // Light grouped backgrounds (iOS Settings 톤)
  static const Color groupedBgLight = Color(0xFFF2F2F7);
  static const Color groupedSurfaceLight = Color(0xFFFFFFFF);

  // Dark grouped backgrounds
  static const Color groupedBgDark = Color(0xFF000000);
  static const Color groupedSurfaceDark = Color(0xFF1C1C1E);
  static const Color groupedSurfaceElevatedDark = Color(0xFF2C2C2E);

  // Separators
  static const Color separatorLight = Color(0x33000000); // 20% black
  static const Color separatorDark = Color(0x33FFFFFF); // 20% white

  // Text
  static const Color labelLight = Color(0xFF000000);
  static const Color labelDark = Color(0xFFFFFFFF);
  static const Color secondaryLabelLight = Color(0x993C3C43); // 60% #3C3C43
  static const Color secondaryLabelDark = Color(0x99EBEBF5);

  // Card tint colors (Card Stack 시각 변주용)
  static const Color cardTintFromLight = Color(0xFFE3F2FD); // soft blue
  static const Color cardTintToLight = Color(0xFFEDE7F6); // soft indigo
  static const Color cardTintFromDark = Color(0xFF1A2942);
  static const Color cardTintToDark = Color(0xFF22203A);
}

final ColorScheme kLightScheme =
    ColorScheme.fromSeed(seedColor: IosPalette.systemBlue, brightness: Brightness.light).copyWith(
      primary: IosPalette.systemBlue,
      onPrimary: Colors.white,
      surface: IosPalette.groupedBgLight,
      onSurface: IosPalette.labelLight,
      surfaceContainerHighest: IosPalette.groupedSurfaceLight,
      surfaceContainer: IosPalette.groupedSurfaceLight,
      outline: IosPalette.separatorLight,
    );

final ColorScheme kDarkScheme =
    ColorScheme.fromSeed(
      seedColor: IosPalette.systemBlueDark,
      brightness: Brightness.dark,
    ).copyWith(
      primary: IosPalette.systemBlueDark,
      onPrimary: Colors.white,
      surface: IosPalette.groupedBgDark,
      onSurface: IosPalette.labelDark,
      surfaceContainerHighest: IosPalette.groupedSurfaceDark,
      surfaceContainer: IosPalette.groupedSurfaceElevatedDark,
      outline: IosPalette.separatorDark,
    );
