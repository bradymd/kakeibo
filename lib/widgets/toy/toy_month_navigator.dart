import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// `< Month Year >` navigator for moving between months — forward into
/// the future or back through completed months. Kept from the original
/// dashboard (`lib/widgets/month_navigator.dart`); the redesign must
/// not lose the ability to view a month other than the current one.
class ToyMonthNavigator extends StatelessWidget {
  const ToyMonthNavigator({
    super.key,
    required this.displayText,
    required this.onPrevious,
    required this.onNext,
  });

  final String displayText;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 0, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Arrow(icon: Icons.chevron_left_rounded, onTap: onPrevious),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              displayText,
              style: ToyTextStyles.rowAmount(fontSize: 14, color: ToyColors.brand),
            ),
          ),
          _Arrow(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, color: ToyColors.brand, size: 22),
      ),
    );
  }
}
