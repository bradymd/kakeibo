import 'package:flutter/material.dart';

/// Colour tokens for the "gachapon" (toy-capsule-machine) redesign.
///
/// Values are taken verbatim from the design handoff README's colour
/// table. Keep names matched to the README's token names so the two stay
/// easy to cross-reference.
class ToyColors {
  const ToyColors._();

  // Screen backgrounds
  static const bg = Color(0xFFFFF1F5);
  static const bgGoal = Color(0xFFFFF9EC); // goal-hit state only (5d)

  // Brand
  static const brand = Color(0xFFE8447C); // header fill, wants pillar
  static const brandDark = Color(0xFFC22B60); // active tab pill fill
  static const brandShadow = Color(0xFFB32A5C); // shadow under active pill

  // Cards / surfaces
  static const card = Color(0xFFFFFFFF);
  static const cardShadow = Color(0xFFF3B9CD);
  static const divider = Color(0xFFF3D3DE);

  // Gold (primary actions)
  static const gold = Color(0xFFFFD24C);
  static const goldShadow = Color(0xFFD9A400);
  static const goldInk = Color(0xFF7A5600);
  static const goldSoft = Color(0xFFFFE07A);
  static const goldBg = Color(0xFFFFF7DC); // tip-jar card
  static const goldBg2 = Color(0xFFFFF3CE); // spare-money tile

  // Text
  static const ink = Color(0xFF5B3A45);
  static const ink2 = Color(0xFF7A5E68);
  static const muted = Color(0xFF7E5F6B);
  static const muted2 = Color(0xFF9A7B86);
  static const placeholder = Color(0xFFB3808F);
  static const chevron = Color(0xFFC9A9B5);

  // Semantic
  static const success = Color(0xFF1F8A63);
  static const successDark = Color(0xFF0C6B4E);
  static const mint = Color(0xFFD8F6EA);
  static const dangerHeader = Color(0xFF8E3550); // over-budget header
  static const dangerHeaderSubtitle = Color(0xFFFFC9D8); // subtitle on it
  static const danger = Color(0xFFB3243F);
  static const dangerHatch = Color(0xFF7A0F27);
  static const wolfCard = Color(0xFF3A2A2F);
  static const wolfPink = Color(0xFFFF8FA8);
  static const amberBg = Color(0xFFFFE8D6); // payday card
  static const amberInk = Color(0xFF8A5A12);
}

/// Pillar colours for the toy theme. These replace the muted set in
/// `lib/models/pillar.dart` for *display only* — the `Pillar` enum
/// itself (names, order) must never change, since it is persisted.
class ToyPillarColors {
  const ToyPillarColors._();

  static const needsFill = Color(0xFF38C39A);
  static const needsInk = Color(0xFF0C3E2E);

  static const wantsFill = Color(0xFFE8447C);
  static const wantsInk = Color(0xFFFFFFFF);

  static const cultureFill = Color(0xFF8B5CF6);
  static const cultureInk = Color(0xFFFFFFFF);

  static const unexpectedFill = Color(0xFFF97316);
  static const unexpectedInk = Color(0xFF4A1F00);

  // Darker ring shades used for the selected state in the Add Expense
  // pillar picker (README §4a).
  static const needsRing = Color(0xFF0C3E2E);
  static const wantsRing = Color(0xFF7A1136);
  static const cultureRing = Color(0xFF3B1A80);
  static const unexpectedRing = Color(0xFF4A1F00);

  // Dark ink variants used for capsule filter labels (README §3a).
  static const wantsFilterInk = Color(0xFFA81B52);
  static const cultureFilterInk = Color(0xFF5B2CB0);
  static const unexpectedFilterInk = Color(0xFF8A3A00);
}
