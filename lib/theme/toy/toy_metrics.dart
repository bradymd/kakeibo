/// Spacing and radius constants for the toy theme, from the README's
/// "Spacing, radius, shadow" section.
class ToyMetrics {
  const ToyMetrics._();

  // Padding
  static const double screenPaddingH = 17; // 16–18 horizontal
  static const double cardPadding = 16;
  static const double rowPaddingV = 12;
  static const double rowPaddingH = 14;

  // Gaps
  static const double cardGap = 14;
  static const double gridTileGap = 9.5; // 9–10
  static const double keypadGap = 8;
  static const double pillGap = 7.5; // 7–8

  // Radii
  static const double cardRadius = 24; // 22–26
  static const double tileRadius = 16; // 14–20
  static const double capsuleFilterRadius = 20;
  static const double fabRadius = 32; // 64x64 FAB
  static const double fabSize = 64;
  static const double checkboxRadius = 8;
  static const double keypadKeyRadius = 14;

  // Bottom padding so scrollable lists clear the FAB (README: "Lists
  // must carry padding-bottom: 84 so the last row scrolls clear of it").
  static const double listBottomPadding = 84;

  // Minimum tap target (README acceptance check).
  static const double minTapTarget = 44;
}
