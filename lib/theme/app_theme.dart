import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

class AppTheme {
  const AppTheme._();

  /// The theme actually applied by `MaterialApp`.
  static ThemeData get current => ToyTheme.light;
}
