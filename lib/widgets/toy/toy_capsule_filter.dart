import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// One capsule filter pill, as used on the Spend screen's filter row
/// (README §3a): white, radius 20, padding `7 13`, 11.5/800, shadow
/// `0 3px 0 #F3D3DE`. Selected gets a 2.5px ring in [ringColor].
///
/// Tapping the already-selected pill does not deselect it — that
/// decision belongs to the caller (only `All` should clear a filter),
/// so this widget just reports taps via [onTap] and reflects
/// [selected].
class ToyCapsuleFilter extends StatelessWidget {
  const ToyCapsuleFilter({
    super.key,
    required this.label,
    required this.selected,
    required this.textColor,
    this.onTap,
    this.ringColor,
  });

  final String label;
  final bool selected;
  final Color textColor;
  final VoidCallback? onTap;

  /// Ring colour when selected. Defaults to [textColor] if omitted.
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    return ToyPressable(
      restOffset: 3,
      pressedOffset: 1,
      onTap: onTap,
      builder: (context, offset) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: ToyColors.card,
          borderRadius: BorderRadius.circular(ToyMetrics.capsuleFilterRadius),
          border: selected
              ? Border.all(color: ringColor ?? textColor, width: 2.5)
              : null,
          boxShadow: ToyShadows.small(color: ToyColors.divider, offset: offset),
        ),
        child: Text(
          label,
          style: ToyTextStyles.label(fontSize: 11.5, color: textColor)
              .copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

/// Horizontal scrollable row of [ToyCapsuleFilter]s with the README's
/// gaps/padding (`padding: 12 14 10`, `gap: 7`).
class ToyCapsuleFilterRow extends StatelessWidget {
  const ToyCapsuleFilterRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: ToyMetrics.pillGap),
            children[i],
          ],
        ],
      ),
    );
  }
}
