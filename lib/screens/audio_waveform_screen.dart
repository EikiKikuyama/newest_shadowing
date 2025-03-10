import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../services/audio_player_service.dart';

class AudioWaveformScreen extends StatefulWidget {
  const AudioWaveformScreen({super.key});

  @override
  AudioWaveformScreenState createState() => AudioWaveformScreenState();
}

class AudioWaveformScreenState extends State<AudioWaveformScreen> {
  List<double> fullWaveform = [];
  List<double> currentWaveform = [];
  double maxAmplitude = 1.5;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String? filePath;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  DateTime? lastUpdateTime;
  int displayDurationMs = 10000;
  double progress = 0.0;
  @override
  void initState() {
    super.initState();
    _loadAudio();
    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (lastUpdateTime == null ||
          DateTime.now().difference(lastUpdateTime!) >
              Duration(milliseconds: 1000)) {
        if (mounted) {
          setState(() {
            currentPosition = position;
            _updateWaveform();
          });
        }
        lastUpdateTime = DateTime.now();
      }
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          totalDuration = duration;
        });
      }
    });
  }

  Future<void> _loadAudio() async {
    filePath = await AudioPlayerService().copyAssetToFile("mount_fuji.mp3");
    if (filePath == null || filePath!.isEmpty) return;

    fullWaveform = await compute(extractWaveform, File(filePath!));

    // ✅ 波形データをスムージング
    if (fullWaveform.isNotEmpty) {
      fullWaveform = _processWaveform(fullWaveform);
    }

    maxAmplitude = fullWaveform.reduce(max) * 1.5;

    if (mounted) {
      setState(() {
        currentWaveform = fullWaveform;
      });
    }
  }

  static List<double> extractWaveform(File file) {
    final List<double> amplitudes = [];
    final Uint8List data = file.readAsBytesSync();
    int step = 50; // ✅ 解像度を上げる（100バイトごとにサンプリング）

    for (int i = 0; i < data.length - 1; i += step) {
      int sample = (data[i] | (data[i + 1] << 8)).toSigned(16);
      amplitudes.add(sample.toDouble());
    }

    return amplitudes;
  }

  List<double> _processWaveform(List<double> waveform) {
    if (waveform.isEmpty) return [];

    // ✅ マイナス値を削除し、すべて0以上に
    List<double> processed =
        waveform.map((value) => max(0, value).toDouble()).toList();

    int numSamplesPerSecond = 30;
    int windowSize = (processed.length / numSamplesPerSecond).floor();

    if (windowSize <= 0) {
      print("⚠️ データが少なすぎるため処理をスキップ");
      return processed;
    }

    List<double> smoothedWaveform = [];

    // ✅ 移動平均フィルター（波形を滑らかに）
    for (int i = 0; i < processed.length - windowSize; i++) {
      double avg =
          processed.sublist(i, i + windowSize).reduce((a, b) => a + b) /
              windowSize;
      smoothedWaveform.add(avg);
    }

    return smoothedWaveform.map((e) => e / 10).toList();
  }

  List<double> smoothWaveform(List<double> input, {int windowSize = 5}) {
    List<double> output = List.filled(input.length, 0);
    for (int i = 0; i < input.length; i++) {
      int start = (i - windowSize).clamp(0, input.length - 1);
      int end = (i + windowSize).clamp(0, input.length - 1);
      output[i] = input.sublist(start, end + 1).reduce((a, b) => a + b) /
          (end - start + 1);
    }
    return output;
  }

  void _toggleAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (filePath == null) return;
      await _audioPlayer.setSourceDeviceFile(filePath!);
      await _audioPlayer.resume();
    }
    if (mounted) {
      setState(() {
        isPlaying = !isPlaying;
      });
    }
  }

  void _updateWaveform() {
    if (fullWaveform.isEmpty || totalDuration.inMilliseconds == 0) return;

    int totalSamples = fullWaveform.length;
    int totalDurationMs = totalDuration.inMilliseconds;
    int currentMs = currentPosition.inMilliseconds;

    // ✅ オフセット (-3000, +3000) を削除し、正確な範囲を計算
    // 🎯 描画範囲をもっと広げる
    int startIndex = (currentMs / totalDurationMs * totalSamples)
        .clamp(0, totalSamples - 1)
        .toInt();
    int endIndex = ((currentMs + 5000) / totalDurationMs * totalSamples)
        .clamp(0, totalSamples)
        .toInt();

    List<double> newWaveform = fullWaveform.sublist(startIndex, endIndex);
    double newProgress = currentMs / totalDurationMs;

    // ✅ 更新間隔を 100ms に短縮
    if (DateTime.now()
            .difference(lastUpdateTime ?? DateTime(0))
            .inMilliseconds <
        100) {
      return;
    }

    lastUpdateTime = DateTime.now();

    if (mounted) {
      setState(() {
        currentWaveform = newWaveform;
        progress = newProgress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("音声の波形表示")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _toggleAudio,
            child: Text(isPlaying ? "停止" : "再生"),
          ),
          SizedBox(
            height: 280,
            width: double.infinity,
            child: CustomPaint(
              painter: LineWavePainter(
                amplitudes: currentWaveform,
                maxAmplitude: maxAmplitude,
                progress: currentPosition.inMilliseconds /
                    totalDuration.inMilliseconds, // ✅ 修正後
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LineWavePainter extends CustomPainter {
  final List<double> amplitudes;
  final double maxAmplitude;
  final double progress; // 進行度（0.0 - 1.0）

  LineWavePainter({
    required this.amplitudes,
    required this.maxAmplitude,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty || maxAmplitude <= 0 || maxAmplitude.isNaN) return;

    final Paint pastWavePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Paint redLinePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.5;

    final Paint futureWavePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    double centerX = size.width / 2;
    double scrollOffset = progress * size.width;

    Path pastPath = Path();
    Path futurePath = Path();

    bool hasPastPathStarted = false;
    bool hasFuturePathStarted = false;

    for (int i = 0; i < amplitudes.length - 1; i++) {
      double x1 = centerX +
          ((i - amplitudes.length / 2) / amplitudes.length) * size.width -
          scrollOffset;
      double y1 = size.height / 2 -
          ((amplitudes[i] / maxAmplitude) * size.height * 0.6);
      double x2 = centerX +
          (((i + 1) - amplitudes.length / 2) / amplitudes.length) * size.width -
          scrollOffset;
      double y2 = size.height / 2 -
          ((amplitudes[i + 1] / maxAmplitude) * size.height * 0.6);

      if (y1.isNaN || y1.isInfinite || y2.isNaN || y2.isInfinite) continue;

      if (x1 < centerX) {
        // 過去の波形（青）
        if (!hasPastPathStarted) {
          pastPath.moveTo(x1, y1);
          hasPastPathStarted = true;
        }
        pastPath.lineTo(x2, y2);
      } else {
        // 未来の波形（グレー）
        if (!hasFuturePathStarted) {
          futurePath.moveTo(x1, y1);
          hasFuturePathStarted = true;
        }
        futurePath.lineTo(x2, y2);
      }
    }

    // 過去の波形を描画（青）
    canvas.drawPath(pastPath, pastWavePaint);

    // 未来の波形を描画（グレー）
    canvas.drawPath(futurePath, futureWavePaint);

    // 再生位置を示す赤いライン
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      redLinePaint,
    );
  }

  @override
  bool shouldRepaint(LineWavePainter oldDelegate) => true;
}
