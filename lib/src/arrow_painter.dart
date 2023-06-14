import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  final Color color;
  final double size;

  ArrowPainter({
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final size = this.size / 5;
    final halfSize = this.size / 2;

    final path = Path()
      ..moveTo(halfSize, 0)
      ..lineTo(halfSize + size, size)
      ..quadraticBezierTo(
        halfSize,
        this.size / 15,
        halfSize - size,
        size,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) {
    return oldDelegate.color != color && oldDelegate.size != size;
  }

  @override
  bool shouldRebuildSemantics(ArrowPainter oldDelegate) => false;
}
