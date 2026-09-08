import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// One destination in the toy tab bar. These are the four things
/// tracked *during* the month; the two bookend rituals (Start of
/// Month, End of Month / Reflect) live in the hamburger menu instead —
/// see `toy_menu_button.dart`.
enum ToyTabDestination {
  month('/', '家計簿', 'Month'),
  spend('/expenses', '支出', 'Spent'),
  fixed('/fixed-expenses', '固定費', 'Fixed'),
  income('/income', '収入', 'Income');

  const ToyTabDestination(this.path, this.japanese, this.label);

  final String path;
  final String japanese;
  final String label;
}

/// The four-pill bottom tab bar (README "Global chrome"): replaces the
/// invisible swipe-only navigation with a visible structure. The
/// existing horizontal swipe (`lib/services/swipe_nav.dart`) is kept as
/// a shortcut alongside this, not removed.
///
/// White bar, shadow `0 -3px 0 #F3B9CD`, padding `12 18 24`. Active
/// pill: `#C22B60` fill, white text, shadow `0 4px 0 #B32A5C`. Inactive:
/// `#FFEAF1` fill, `#8A5B6B` text, shadow `0 4px 0 #F3D3DE`.
class ToyTabBar extends StatelessWidget {
  const ToyTabBar({
    super.key,
    required this.current,
    this.disabled = const {},
    this.pathOverrides = const {},
  });

  /// The currently active destination.
  final ToyTabDestination current;

  /// Destinations to render disabled (README §5b: before a month is set
  /// up, Spend and Income are disabled).
  final Set<ToyTabDestination> disabled;

  /// Per-destination path overrides, used only while the redesign is
  /// mid-rollout: screens not yet converted don't have a toy version to
  /// link to, so a converted screen can point its tab bar at the other
  /// converted screens' preview routes instead of the real ones. Remove
  /// once every destination has a converted screen at its real route.
  final Map<ToyTabDestination, String> pathOverrides;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      decoration: const BoxDecoration(
        color: ToyColors.card,
        boxShadow: [
          BoxShadow(color: ToyColors.cardShadow, blurRadius: 0, offset: Offset(0, -3)),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < ToyTabDestination.values.length; i++) ...[
            if (i > 0) const SizedBox(width: ToyMetrics.pillGap),
            Expanded(
              child: _TabPill(
                destination: ToyTabDestination.values[i],
                active: ToyTabDestination.values[i] == current,
                enabled: !disabled.contains(ToyTabDestination.values[i]),
                path: pathOverrides[ToyTabDestination.values[i]] ??
                    ToyTabDestination.values[i].path,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.destination,
    required this.active,
    required this.enabled,
    required this.path,
  });

  final ToyTabDestination destination;
  final bool active;
  final bool enabled;
  final String path;

  @override
  Widget build(BuildContext context) {
    final fill = active
        ? ToyColors.brandDark
        : enabled
            ? const Color(0xFFFFEAF1)
            : const Color(0xFFFFEAF1).withValues(alpha: 0.5);
    final textColor = active
        ? Colors.white
        : enabled
            ? const Color(0xFF8A5B6B)
            : const Color(0xFFC4A3B0);
    final shadowColor = active ? ToyColors.brandShadow : ToyColors.divider;

    return ToyPressable(
      restOffset: 4,
      pressedOffset: 1,
      onTap: enabled && !active ? () => context.go(path) : null,
      builder: (context, offset) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
          boxShadow: enabled
              ? ToyShadows.small(color: shadowColor, offset: offset)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          destination.label,
          style: ToyTextStyles.label(fontSize: 11, color: textColor)
              .copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
