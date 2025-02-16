import 'package:flutter/material.dart';

class AudioWavePainter extends CustomPainter {
  final List<double> amplitudes;
  final double maxAmplitude;

  AudioWavePainter(this.amplitudes, {this.maxAmplitude = 100.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    double centerY = size.height / 2;

    if (amplitudes.isEmpty) return;

    double scaleFactor = size.height / (maxAmplitude * 2); // 振幅をスケール

    for (int i = 0; i < amplitudes.length; i++) {
      double x = (i / (amplitudes.length - 1)) * size.width;
      double y = centerY - amplitudes[i] * scaleFactor; // Y座標のスケール適用

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
