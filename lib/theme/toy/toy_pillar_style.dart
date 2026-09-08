import 'package:flutter/material.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/theme/toy/toy_colors.dart';

/// Presentation-only mapping from [Pillar] to the toy theme's colours.
///
/// Deliberately kept separate from `Pillar.color` in
/// `lib/models/pillar.dart` — that enum is persisted by name and must
/// never be renamed or reordered. This class only supplies *look*, not
/// identity, so the toy theme can be swapped in/out via [kToyTheme]
/// without touching stored data.
extension ToyPillarStyle on Pillar {
  /// Capsule / dominant fill colour.
  Color get toyFill {
    switch (this) {
      case Pillar.needs:
        return ToyPillarColors.needsFill;
      case Pillar.wants:
        return ToyPillarColors.wantsFill;
      case Pillar.culture:
        return ToyPillarColors.cultureFill;
      case Pillar.unexpected:
        return ToyPillarColors.unexpectedFill;
    }
  }

  /// Text/ink colour to use on top of [toyFill].
  Color get toyInkOnFill {
    switch (this) {
      case Pillar.needs:
        return ToyPillarColors.needsInk;
      case Pillar.wants:
        return ToyPillarColors.wantsInk;
      case Pillar.culture:
        return ToyPillarColors.cultureInk;
      case Pillar.unexpected:
        return ToyPillarColors.unexpectedInk;
    }
  }

  /// Darker ring colour for the selected state in the Add Expense
  /// pillar picker (README §4a).
  Color get toySelectedRing {
    switch (this) {
      case Pillar.needs:
        return ToyPillarColors.needsRing;
      case Pillar.wants:
        return ToyPillarColors.wantsRing;
      case Pillar.culture:
        return ToyPillarColors.cultureRing;
      case Pillar.unexpected:
        return ToyPillarColors.unexpectedRing;
    }
  }

  /// Dark ink used for capsule filter labels on the Spend screen
  /// (README §3a). `All` uses `ToyColors.ink` directly, not this getter.
  Color get toyFilterInk {
    switch (this) {
      case Pillar.needs:
        return ToyPillarColors.needsInk;
      case Pillar.wants:
        return ToyPillarColors.wantsFilterInk;
      case Pillar.culture:
        return ToyPillarColors.cultureFilterInk;
      case Pillar.unexpected:
        return ToyPillarColors.unexpectedFilterInk;
    }
  }

  /// Japanese short label, e.g. 必要. Already on [Pillar.japanese]; kept
  /// here as a passthrough so screens can import one extension for all
  /// toy-theme pillar presentation needs.
  String get toyJapanese => japanese;
}
