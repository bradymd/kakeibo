import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_colors.dart';
import 'package:kakeibo/theme/toy/toy_metrics.dart';

export 'package:kakeibo/theme/toy/toy_colors.dart';
export 'package:kakeibo/theme/toy/toy_metrics.dart';
export 'package:kakeibo/theme/toy/toy_painters.dart';
export 'package:kakeibo/theme/toy/toy_pillar_style.dart';
export 'package:kakeibo/theme/toy/toy_pressable.dart';
export 'package:kakeibo/theme/toy/toy_shadows.dart';
export 'package:kakeibo/theme/toy/toy_text_styles.dart';

/// `ThemeData` for the "gachapon" redesign, selected in `app_theme.dart`
/// when `kToyTheme` is true. Mirrors the structure of `AppTheme.light`
/// so the two are easy to diff.
class ToyTheme {
  const ToyTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ToyColors.brand,
        primary: ToyColors.brand,
        secondary: ToyColors.gold,
        tertiary: ToyColors.mint,
        surface: ToyColors.card,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: ToyColors.bg,
      // Bundled asset font (see toy_text_styles.dart) rather than
      // google_fonts' runtime-fetched TextTheme -- fontFamily here just
      // sets the app-wide default; ToyTextStyles explicitly sets it too
      // on every style it returns, so this mainly covers stray Text
      // widgets that don't go through ToyTextStyles.
      textTheme: ThemeData.light().textTheme.apply(
            fontFamily: 'MPLUSRounded1c',
            bodyColor: ToyColors.ink,
            displayColor: ToyColors.ink,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ToyMetrics.cardRadius),
        ),
        color: ToyColors.card,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ToyColors.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
          borderSide: const BorderSide(color: ToyColors.brand, width: 2),
        ),
        hintStyle: const TextStyle(color: ToyColors.placeholder),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ToyColors.gold,
          foregroundColor: ToyColors.goldInk,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ToyColors.gold,
        foregroundColor: ToyColors.goldInk,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(ToyMetrics.fabRadius)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ToyColors.divider,
        thickness: 1,
      ),
    );
  }
}
