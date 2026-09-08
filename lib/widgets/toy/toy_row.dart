import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// The shared row anatomy used on Spend, Fixed costs, Income and Search
/// results (README §3a/§4d/§4e/§4f): a leading dot/chip, title, meta
/// line, trailing amount. Padding `12 14`.
///
/// Rows are separated by a [DashedDivider] — this widget draws only the
/// row's own content, not the divider, so callers can lay out
/// `ListView.separated` or a manual `Column` with `DashedDivider`
/// between items.
class ToyRow extends StatelessWidget {
  const ToyRow({
    super.key,
    required this.title,
    this.meta,
    this.amountText,
    this.amountColor = ToyColors.ink,
    this.leading,
    this.onTap,
  });

  final String title;
  final String? meta;
  final String? amountText;
  final Color amountColor;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: ToyTextStyles.rowTitle(),
                  overflow: TextOverflow.ellipsis,
                ),
                if (meta != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    meta!,
                    style: ToyTextStyles.label(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ToyColors.muted2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (amountText != null) ...[
            const SizedBox(width: 8),
            Text(
              amountText!,
              style: ToyTextStyles.rowAmount(color: amountColor),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: content);
  }
}

/// 24px pillar dot with inner bottom shade, used as [ToyRow.leading] on
/// the Spend screen (README §3a).
class ToyPillarDot extends StatelessWidget {
  const ToyPillarDot({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: color)),
            const Positioned.fill(child: CapsuleInnerShade()),
          ],
        ),
      ),
    );
  }
}
