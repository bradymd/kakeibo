import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// A quiet, centred text link used for infrequent secondary actions that
/// shouldn't compete visually with the primary content above them -- e.g.
/// "Copy from another month" below the Fixed Costs/Income list, once the
/// gold capsule version was judged too prominent for a month that already
/// has entries (see Codex's review in the shared design discussion:
/// copying is monthly-setup assistance, not the daily/primary action, so
/// it shouldn't outrank the `+` FAB for visual weight once there's
/// something to copy *from* rather than *into*).
///
/// Distinct from a capsule/button on purpose -- this is a link, not a
/// call to action.
class ToyLinkRow extends StatelessWidget {
  const ToyLinkRow({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: ToyTextStyles.label(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: ToyColors.brand,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 17, color: ToyColors.brand),
            ],
          ),
        ),
      ),
    );
  }
}
