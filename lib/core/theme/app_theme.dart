import 'package:flutter/material.dart';

import 'color_schemes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: kLightScheme,
    textTheme: Typography.material2021().black,
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: kDarkScheme,
    textTheme: Typography.material2021().white,
  );
}
