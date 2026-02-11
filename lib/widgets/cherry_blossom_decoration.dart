import 'dart:math';
import 'package:flutter/material.dart';

class CherryBlossomDecoration extends StatelessWidget {
  const CherryBlossomDecoration({super.key, this.opacity = 0.15});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CherryBlossomPainter(opacity: opacity),
      size: Size.infinite,
    );
  }
}

class _CherryBlossomPainter extends CustomPainter {
  _CherryBlossomPainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent rendering
    final petals = <_Petal>[];

    for (int i = 0; i < 12; i++) {
      petals.add(_Petal(
        x: random.nextDouble() * size.width,
        y: random.nextDouble() * size.height,
        size: 6 + random.nextDouble() * 10,
        rotation: random.nextDouble() * pi * 2,
        alpha: (0.3 + random.nextDouble() * 0.5) * opacity,
      ));
    }

    for (final petal in petals) {
      _drawPetal(canvas, petal);
    }
  }

  void _drawPetal(Canvas canvas, _Petal petal) {
    final paint = Paint()
      ..color = Color(0xFFFF9CC2).withValues(alpha: petal.alpha)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(petal.x, petal.y);
    canvas.rotate(petal.rotation);

    final path = Path();
    path.moveTo(0, -petal.size / 2);
    path.quadraticBezierTo(
        petal.size / 2, -petal.size / 4, petal.size / 4, petal.size / 4);
    path.quadraticBezierTo(0, petal.size / 2, -petal.size / 4, petal.size / 4);
    path.quadraticBezierTo(
        -petal.size / 2, -petal.size / 4, 0, -petal.size / 2);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Petal {
  final double x, y, size, rotation, alpha;
  const _Petal({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.alpha,
  });
}
