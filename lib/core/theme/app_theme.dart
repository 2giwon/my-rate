import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'color_schemes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _buildTheme(kLightScheme, Brightness.light);
  static ThemeData dark() => _buildTheme(kDarkScheme, Brightness.dark);

  static ThemeData _buildTheme(ColorScheme scheme, Brightness brightness) {
    final base = Typography.material2021();
    final tt = brightness == Brightness.light ? base.black : base.white;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      // iOS는 AppBar가 거의 투명/배경동일색.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      // Card 기본값: 흰색/짙은 회색 surface, 모서리 22, 그림자 거의 없음
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        margin: EdgeInsets.zero,
      ),
      // iOS는 fillColor를 살짝 어두운 회색으로
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      textTheme: tt.copyWith(
        displayLarge: tt.displayLarge?.copyWith(
          fontSize: 60,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        headlineMedium: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        titleLarge: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: tt.bodyLarge?.copyWith(fontSize: 16),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: scheme.primary,
        brightness: brightness,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.3),
        space: 1,
        thickness: 0.5,
      ),
    );
  }
}
