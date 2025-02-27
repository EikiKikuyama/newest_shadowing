import 'package:flutter/material.dart';

class AudioWavePainter extends CustomPainter {
  final List<double> amplitudes;
  final double heightFactor;

  AudioWavePainter({this.amplitudes = const [], this.heightFactor = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) {
      print("⚠️ 空の波形データなので描画をスキップ");
      return;
    }

    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double baseline = size.height; // 波形の基準を下にする
    final double widthStep = size.width / amplitudes.length;

    final Path path = Path();
    for (int i = 0; i < amplitudes.length; i++) {
      final double normalized =
          (amplitudes[i].abs() * heightFactor) * size.height;

      if (normalized.isNaN || normalized.isInfinite) {
        print(
            "⚠️ 無効な値が検出されました: amplitudes[$i] = ${amplitudes[i]}, normalized = $normalized");
        continue;
      }

      final double x = i * widthStep;
      final double y = baseline - normalized; // 下から描画（下半分を削除）

      path.moveTo(x.clamp(0, size.width), baseline);
      path.lineTo(x.clamp(0, size.width), y.clamp(0, size.height));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
