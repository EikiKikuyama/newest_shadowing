import 'package:flutter/material.dart';

class AudioWavePainter extends CustomPainter {
  final List<double> amplitudes;

  AudioWavePainter({required this.amplitudes});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.5 // 🎯 波形を細くして見やすく
      ..style = PaintingStyle.stroke;

    if (amplitudes.isEmpty) return;

    final Path path = Path();
    double widthStep = size.width / amplitudes.length;
    double centerY = size.height / 2;

    path.moveTo(0, centerY - amplitudes[0] * centerY);

    for (int i = 1; i < amplitudes.length; i++) {
      double x = i * widthStep;
      double y = centerY - amplitudes[i] * centerY;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    final Paint axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), axisPaint);
  }

  @override
  bool shouldRepaint(covariant AudioWavePainter oldDelegate) {
    return amplitudes != oldDelegate.amplitudes;
  }
}
