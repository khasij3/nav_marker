import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  final Color arrowColor;
  final Color bodyColor;
  final double size;

  ArrowPainter({
    required this.arrowColor,
    required this.bodyColor,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = bodyColor;
    final arrowPaint = Paint()..color = arrowColor;
    final arrowSize = this.size / 5;
    final halfSize = this.size / 2;
    final center = Offset(halfSize, halfSize);

    final path = Path()
      ..moveTo(halfSize, 0)
      ..lineTo(halfSize + arrowSize, arrowSize)
      ..quadraticBezierTo(
        halfSize,
        this.size / 15,
        halfSize - arrowSize,
        arrowSize,
      )
      ..close();

    canvas.drawCircle(center, this.size / 3, bodyPaint);
    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(ArrowPainter oldDelegate) => false;
}
