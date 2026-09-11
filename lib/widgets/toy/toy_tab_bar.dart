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
///
/// Used as [ToyScaffold]'s `bottomNavigationBar`, not a plain child inside
/// its body -- that's what lets Scaffold measure this bar and set
/// `ScaffoldPrelayoutGeometry.contentBottom` correctly, which the FAB
/// (positioned via the standard `endFloat`) relies on. Confirmed against
/// Flutter's own Scaffold/SafeArea source, not assumed: this used to be a
/// plain child in a Column with a hardcoded bottom-24 padding, which left
/// a real Android phone's own 3-button navigation bar drawn directly on
/// top of the tab pills (untappable) since the device's actual bottom
/// safe-area inset was never consulted at all.
///
/// The bottom 24 is the *minimum* visual breathing room, not something to
/// stack on top of the device inset -- `SafeArea.minimum` takes
/// `max(24, device inset)` rather than `24 + device inset`, so a tall
/// gesture-nav inset doesn't make the bar look emptily over-tall, and a
/// device with no inset at all still gets the original 24px look.
///
/// Each pill is given an explicit 44px height (see the `SizedBox` around
/// `_TabPill` below) rather than being left to size itself naturally.
/// This isn't cosmetic: Scaffold gives `bottomNavigationBar` a *finite*
/// loose vertical constraint (the Scaffold's own height), which the Row
/// passes down to its Expanded children -- so `_TabPill`'s Container,
/// which has a non-null `alignment`, would otherwise expand to fill that
/// entire bounded height (confirmed by Codex: this genuinely happened,
/// each pill rendered ~564px tall and covered the whole screen, silently
/// swallowing every touch meant for the body underneath, including the
/// swipe-to-delete Dismissible on the Spend screen -- a real regression
/// caught by test/toy_all_expenses_dismiss_test.dart). In the old
/// body-Column placement this same Container had an *unbounded* height to
/// shrink-wrap against, so the bug never showed there. 44px also slightly
/// improves the old ~39px pill's touch target.
class ToyTabBar extends StatelessWidget {
  const ToyTabBar({
    super.key,
    required this.current,
    this.disabled = const {},
  });

  /// The currently active destination.
  final ToyTabDestination current;

  /// Destinations to render disabled (README §5b: before a month is set
  /// up, Spend and Income are disabled).
  final Set<ToyTabDestination> disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ToyColors.card,
        boxShadow: [
          BoxShadow(color: ToyColors.cardShadow, blurRadius: 0, offset: Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: Row(
            children: [
              for (var i = 0; i < ToyTabDestination.values.length; i++) ...[
                if (i > 0) const SizedBox(width: ToyMetrics.pillGap),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: _TabPill(
                      destination: ToyTabDestination.values[i],
                      active: ToyTabDestination.values[i] == current,
                      enabled: !disabled.contains(ToyTabDestination.values[i]),
                      path: ToyTabDestination.values[i].path,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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
