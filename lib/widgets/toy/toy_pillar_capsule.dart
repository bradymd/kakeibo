import 'package:flutter/material.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// A single full-colour pillar capsule tile — used in the dashboard's
/// capsule dome grid (README §2b) and the Add Expense pillar picker
/// (§4a). Radius 16, padding `10 12` (dome) or `11 13` (picker), inner
/// bottom shade, label + amount/description in the pillar's ink colour.
///
/// Pass [selected] to draw the 3px darker ring the picker uses; the
/// dome grid simply omits it (always false, non-interactive there).
class ToyPillarCapsule extends StatelessWidget {
  const ToyPillarCapsule({
    super.key,
    required this.pillar,
    required this.label,
    this.amountText,
    this.onTap,
    this.selected = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.labelFontSize = 11.5,
    this.amountFontSize = 18,
  });

  final Pillar pillar;
  final String label;
  final String? amountText;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsetsGeometry padding;
  final double labelFontSize;
  final double amountFontSize;

  @override
  Widget build(BuildContext context) {
    final ink = pillar.toyInkOnFill;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: pillar.toyFill,
        borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
        border: selected
            ? Border.all(color: pillar.toySelectedRing, width: 3)
            : null,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
              child: const CapsuleInnerShade(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: ToyTextStyles.cardTitle(fontSize: labelFontSize, color: ink)
                    .copyWith(fontWeight: FontWeight.w900),
              ),
              if (amountText != null) ...[
                const SizedBox(height: 2),
                Text(
                  amountText!,
                  style: ToyTextStyles.rowAmount(fontSize: amountFontSize, color: ink)
                      .copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    final tap = onTap;
    if (tap == null) return content;
    return _TappableScale(onTap: tap, child: content);
  }
}

/// Simple press-down scale feedback for tiles with no hard shadow to
/// animate (the capsule is a flat fill, unlike buttons/pills — see
/// [ToyPressable] for the shadow-offset variant used elsewhere).
class _TappableScale extends StatefulWidget {
  const _TappableScale({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_TappableScale> createState() => _TappableScaleState();
}

class _TappableScaleState extends State<_TappableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// 2x2 grid of [ToyPillarCapsule]s, gap 9 per the README.
class ToyPillarCapsuleGrid extends StatelessWidget {
  const ToyPillarCapsuleGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    assert(children.length == 4, 'Expected one capsule per pillar (4)');
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: children[0]),
            const SizedBox(width: ToyMetrics.gridTileGap),
            Expanded(child: children[1]),
          ],
        ),
        const SizedBox(height: ToyMetrics.gridTileGap),
        Row(
          children: [
            Expanded(child: children[2]),
            const SizedBox(width: ToyMetrics.gridTileGap),
            Expanded(child: children[3]),
          ],
        ),
      ],
    );
  }
}
