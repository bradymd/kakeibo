import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_colors.dart';

/// Diagonal stripe overlay for headers: 12px bands at 135°, white at
/// 14% opacity, repeating every 24px. Mirrors the CSS
/// `repeating-linear-gradient(135deg, rgba(255,255,255,.14) 0 12px,
/// transparent 12px 24px)` from the README. Paint this on top of the
/// header's solid fill colour — it does not draw a background itself.
class HeaderStripePainter extends CustomPainter {
  const HeaderStripePainter({this.stripeColor = const Color(0x24FFFFFF)});

  final Color stripeColor;

  static const double _bandWidth = 12;
  static const double _period = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = stripeColor;
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    // Cover the diagonal span generously so rotated bands fill the box.
    final diagonal = size.width + size.height;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(135 * 3.1415926535 / 180);
    canvas.translate(-diagonal, -diagonal);

    for (double x = 0; x < diagonal * 2; x += _period) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, _bandWidth, diagonal * 2),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HeaderStripePainter oldDelegate) =>
      oldDelegate.stripeColor != stripeColor;
}

/// A 1px dashed horizontal line, `#F3D3DE` by default — used between
/// list rows in place of a solid divider.
class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    this.color = ToyColors.divider,
    this.dashWidth = 4,
    this.dashGap = 3,
    this.thickness = 1,
  });

  final Color color;
  final double dashWidth;
  final double dashGap;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: thickness,
      child: CustomPaint(
        size: Size.infinite,
        painter: _DashedLinePainter(
          color: color,
          dashWidth: dashWidth,
          dashGap: dashGap,
          thickness: thickness,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashGap,
    required this.thickness,
  });

  final Color color;
  final double dashWidth;
  final double dashGap;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashGap != dashGap;
}

/// Overspend hatch: `repeating-linear-gradient(135deg, #B3243F 0 5px,
/// #7A0F27 5px 10px)`. Used for the fourth "over budget" segment of the
/// budget bar (README §5a).
class OverspendHatchPainter extends CustomPainter {
  const OverspendHatchPainter({
    this.base = ToyColors.danger,
    this.dark = ToyColors.dangerHatch,
  });

  final Color base;
  final Color dark;

  static const double _bandWidth = 5;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = base);

    final darkPaint = Paint()..color = dark;
    final diagonal = size.width + size.height;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(135 * 3.1415926535 / 180);
    canvas.translate(-diagonal, -diagonal);

    for (double x = 0; x < diagonal * 2; x += _bandWidth * 2) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, _bandWidth, diagonal * 2),
        darkPaint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OverspendHatchPainter oldDelegate) =>
      oldDelegate.base != base || oldDelegate.dark != dark;
}

/// Inner-bottom "capsule shade" — Flutter has no inset shadow, so this
/// paints a soft dark gradient across the bottom of the widget's bounds
/// to fake one. Stack this on top of a capsule/tile's fill.
/// Mirrors `inset 0 -4px 0 rgba(0,0,0,.14)` per the README.
class CapsuleInnerShade extends StatelessWidget {
  const CapsuleInnerShade({super.key, this.opacity = 0.14, this.stopAt = 0.82});

  final double opacity;
  final double stopAt;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [stopAt, 1.0],
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: opacity),
            ],
          ),
        ),
      ),
    );
  }
}

/// Radial "capsule dome" background behind the dashboard's four pillar
/// tiles (README §2b): white centre fading through pale blue to a
/// deeper blue, off-centre toward the top-left.
class CapsuleDomeBackground extends StatelessWidget {
  const CapsuleDomeBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.32, -0.48),
          radius: 0.95,
          colors: [
            Color(0xF2FFFFFF), // white @ ~0.95
            Color(0x8CD6ECFF), // #D6ECFF @ ~0.55
            Color(0x8096C8EB), // #96C8EB @ ~0.5
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// Tiles a 24x24 diagonal-stripe pattern as an [ImageProvider]-free
/// alternative when a `DecorationImage` is preferred over painting
/// directly. Not required for the current screens (the CustomPainter
/// above is used instead) but kept here in case a screen needs the
/// stripes as a repeatable texture rather than a full-size paint.
Future<ui.Image> renderStripeTile({
  double size = 24,
  Color stripeColor = const Color(0x24FFFFFF),
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  HeaderStripePainter(stripeColor: stripeColor).paint(canvas, Size(size, size));
  final picture = recorder.endRecording();
  return picture.toImage(size.toInt(), size.toInt());
}
