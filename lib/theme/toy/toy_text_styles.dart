import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_colors.dart';

/// Text styles for the "gachapon" redesign.
///
/// One family throughout — M PLUS Rounded 1c — for both Japanese and
/// Latin text, at weights 500/700/800/900 (there is no native 600; see
/// the note on [body]). Sizes follow the design handoff README's
/// typography table.
///
/// Bundled as a Flutter asset (pubspec.yaml, assets/fonts/) rather than
/// fetched at runtime via google_fonts -- the previous approach meant
/// first launch contacted fonts.gstatic.com, could render fallback
/// typography or log a load failure entirely offline, and made widget
/// tests network-sensitive (google_fonts' allowRuntimeFetching had to be
/// disabled per-test to avoid exactly that). SIL Open Font License,
/// confirmed via the font files' own embedded metadata.
class ToyTextStyles {
  const ToyTextStyles._();

  static const _fontFamily = 'MPLUSRounded1c';

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    Color color = ToyColors.ink,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      // The bundled family has no native 600 weight -- explicitly
      // substitute 500 rather than rely on Flutter's own nearest-weight
      // matching, whose tie-break behaviour (500 and 700 are both
      // exactly 100 away from 600) isn't guaranteed to match what
      // google_fonts' matching resolved w600 to at runtime before this
      // was bundled.
      fontWeight: fontWeight == FontWeight.w600 ? FontWeight.w500 : fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Hero figure — daily allowance, amount entry. 46–52/900.
  static TextStyle hero({double fontSize = 52, Color? color}) => _base(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: color ?? ToyColors.brand,
      );

  /// Screen total shown in the header. 32–34/900.
  static TextStyle headerTotal({double fontSize = 34, Color color = Colors.white}) =>
      _base(fontSize: fontSize, fontWeight: FontWeight.w900, color: color);

  /// Header title. 19–22/900.
  static TextStyle headerTitle({double fontSize = 20, Color color = Colors.white}) =>
      _base(fontSize: fontSize, fontWeight: FontWeight.w900, color: color);

  /// Header subtitle. 11.5/700, gold-soft on the brand header.
  static TextStyle headerSubtitle({Color color = ToyColors.goldSoft}) =>
      _base(fontSize: 11.5, fontWeight: FontWeight.w700, color: color);

  /// Verdict label — 節約家 / 浪費家. 20/900.
  static TextStyle verdict({Color? color}) => _base(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: color ?? ToyColors.success,
      );

  /// Section / card title. 14.5–17/900.
  static TextStyle cardTitle({double fontSize = 15, Color color = ToyColors.ink}) =>
      _base(fontSize: fontSize, fontWeight: FontWeight.w900, color: color);

  /// Row title. 13.5–14/800.
  static TextStyle rowTitle({double fontSize = 13.5, Color color = ToyColors.ink}) =>
      _base(fontSize: fontSize, fontWeight: FontWeight.w800, color: color);

  /// Row amount. 15–16/900.
  static TextStyle rowAmount({double fontSize = 15, Color color = ToyColors.ink}) =>
      _base(fontSize: fontSize, fontWeight: FontWeight.w900, color: color);

  /// Body copy. 12–12.5/500–600, line-height 1.5–1.7.
  ///
  /// M PLUS Rounded 1c has no native 600 weight -- a w600 request here
  /// renders at 500 (the bundled Medium file), matching exactly what
  /// google_fonts' own closest-available-weight matching already
  /// resolved w600 to at runtime before this was bundled.
  static TextStyle body({
    double fontSize = 12.5,
    FontWeight fontWeight = FontWeight.w500,
    Color color = ToyColors.ink2,
    double height = 1.6,
  }) =>
      _base(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height);

  /// Label / meta text. 11–12.5/700–800.
  static TextStyle label({
    double fontSize = 11.5,
    FontWeight fontWeight = FontWeight.w700,
    Color color = ToyColors.muted2,
  }) =>
      _base(fontSize: fontSize, fontWeight: fontWeight, color: color);

  /// Micro label — all-caps, tracked. 10.5–11/800, letter-spacing
  /// 0.10–0.14em (approximated in logical pixels here).
  static TextStyle microLabel({
    double fontSize = 11,
    Color color = ToyColors.muted2,
    double letterSpacing = 1.2,
  }) =>
      _base(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: letterSpacing,
      );

  /// Status-bar time text. 14/800.
  static TextStyle statusBarTime({Color color = Colors.white}) =>
      _base(fontSize: 14, fontWeight: FontWeight.w800, color: color);
}
