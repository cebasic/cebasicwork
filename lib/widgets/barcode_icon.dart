import 'package:flutter/material.dart';

class BarcodeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const BarcodeIcon({
    Key? key,
    this.size = 24.0,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: BarcodeIconPainter(color: color),
    );
  }
}

class BarcodeIconPainter extends CustomPainter {
  final Color color;

  BarcodeIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.09375 // 6/64 of the original
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final scale = size.width / 64.0;

    // Esquinas
    final cornerPath = Path();
    // Esquina superior izquierda
    cornerPath.moveTo(14 * scale, 8 * scale);
    cornerPath.lineTo(10 * scale, 8 * scale);
    cornerPath.arcToPoint(
      Offset(6 * scale, 12 * scale),
      radius: Radius.circular(4 * scale),
      clockwise: false,
    );
    cornerPath.lineTo(6 * scale, 16 * scale);

    // Esquina superior derecha
    cornerPath.moveTo(50 * scale, 8 * scale);
    cornerPath.lineTo(54 * scale, 8 * scale);
    cornerPath.arcToPoint(
      Offset(58 * scale, 12 * scale),
      radius: Radius.circular(4 * scale),
      clockwise: true,
    );
    cornerPath.lineTo(58 * scale, 16 * scale);

    // Esquina inferior izquierda
    cornerPath.moveTo(14 * scale, 56 * scale);
    cornerPath.lineTo(10 * scale, 56 * scale);
    cornerPath.arcToPoint(
      Offset(6 * scale, 52 * scale),
      radius: Radius.circular(4 * scale),
      clockwise: true,
    );
    cornerPath.lineTo(6 * scale, 48 * scale);

    // Esquina inferior derecha
    cornerPath.moveTo(50 * scale, 56 * scale);
    cornerPath.lineTo(54 * scale, 56 * scale);
    cornerPath.arcToPoint(
      Offset(58 * scale, 52 * scale),
      radius: Radius.circular(4 * scale),
      clockwise: false,
    );
    cornerPath.lineTo(58 * scale, 48 * scale);

    canvas.drawPath(cornerPath, paint);

    // Barras centrales
    final bars = [
      Rect.fromLTWH(13 * scale, 18 * scale, 3 * scale, 28 * scale),
      Rect.fromLTWH(20 * scale, 18 * scale, 6 * scale, 28 * scale),
      Rect.fromLTWH(30 * scale, 18 * scale, 3 * scale, 28 * scale),
      Rect.fromLTWH(37 * scale, 18 * scale, 6 * scale, 28 * scale),
      Rect.fromLTWH(47 * scale, 18 * scale, 3 * scale, 28 * scale),
    ];

    for (final bar in bars) {
      final barPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final roundedRect = RRect.fromRectAndRadius(
        bar,
        Radius.circular(bar.width / 2),
      );
      canvas.drawRRect(roundedRect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
