import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// Full-width primary "gold" button — the main call-to-action shape
/// used across the redesign (Save expense, Start the month, Complete
/// Reflection, etc). README §4a: radius 20, padding `15 0`, `#FFD24C`,
/// shadow `0 6px 0 #D9A400`, label 16/900 `#7A5600`.
class ToyPrimaryButton extends StatelessWidget {
  const ToyPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.fillColor = ToyColors.gold,
    this.shadowColor = ToyColors.goldShadow,
    this.textColor = ToyColors.goldInk,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final Color fillColor;
  final Color shadowColor;
  final Color textColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onTap != null;
    return ToyPressable(
      restOffset: 6,
      pressedOffset: 2,
      onTap: isEnabled ? onTap : null,
      builder: (context, offset) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isEnabled ? fillColor : fillColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: ToyShadows.primary(
            color: isEnabled ? shadowColor : shadowColor.withValues(alpha: 0.4),
            offset: offset,
          ),
        ),
        child: Text(
          label,
          style: ToyTextStyles.rowAmount(fontSize: 16, color: textColor)
              .copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

/// Small chunky "gold capsule" button — used for the copy-from-another-
/// -month action in Fixed Costs/Income's empty state (`別の月からコピー
/// ・ Copy from another month`), where copying is the likely next step.
/// Once the month already has entries, the same action demotes to a quiet
/// ToyLinkRow instead -- gold is the design system's action colour, and a
/// month with real data shouldn't have "copy old data" outrank it visually
/// (see the design discussion for the full reasoning). Radius 20, padding
/// `8 14`, shadow `0 4px 0 #D9A400`.
class ToyCapsuleButton extends StatelessWidget {
  const ToyCapsuleButton({
    super.key,
    required this.label,
    this.onTap,
    this.fillColor = ToyColors.gold,
    this.shadowColor = ToyColors.goldShadow,
    this.textColor = ToyColors.goldInk,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final Color fillColor;
  final Color shadowColor;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ToyPressable(
      restOffset: 4,
      pressedOffset: 1,
      onTap: onTap,
      builder: (context, offset) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: ToyShadows.small(color: shadowColor, offset: offset),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: textColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: ToyTextStyles.label(fontSize: 11.5, color: textColor)
                  .copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

/// White secondary chunky button — e.g. the `PayPal` tip-jar option in
/// README §4h: white fill, shadow `0 5px 0 #F3D3DE`.
class ToySecondaryButton extends StatelessWidget {
  const ToySecondaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.textColor = ToyColors.ink,
  });

  final String label;
  final VoidCallback? onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return ToyPressable(
      restOffset: 5,
      pressedOffset: 1,
      onTap: onTap,
      builder: (context, offset) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ToyColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: ToyShadows.small(color: ToyColors.divider, offset: offset),
        ),
        child: Text(
          label,
          style: ToyTextStyles.rowTitle(fontSize: 14, color: textColor),
        ),
      ),
    );
  }
}
