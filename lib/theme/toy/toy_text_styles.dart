import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/theme/toy/toy_colors.dart';

/// Text styles for the "gachapon" redesign.
///
/// One family throughout — M PLUS Rounded 1c — for both Japanese and
/// Latin text, at weights 500/600/700/800/900. Sizes follow the design
/// handoff README's typography table.
class ToyTextStyles {
  const ToyTextStyles._();

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    Color color = ToyColors.ink,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.mPlusRounded1c(
      fontSize: fontSize,
      fontWeight: fontWeight,
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
