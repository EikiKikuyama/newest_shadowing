import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:newest_shadowing_app/services/audio_wave_painter.dart';
import 'package:path_provider/path_provider.dart';

class AudioWaveformScreen extends StatefulWidget {
  const AudioWaveformScreen({super.key});

  @override
  AudioWaveformScreenState createState() => AudioWaveformScreenState();
}

class AudioWaveformScreenState extends State<AudioWaveformScreen> {
  List<double> fullWaveform = []; // 🎯 全体の波形データ
  List<double> currentWaveform = []; // 🎯 表示する波形データ
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String? filePath;
  Duration currentPosition = Duration.zero; // 🎯 再生位置

  @override
  void initState() {
    super.initState();
    _loadAudio();

    // 🎵 再生位置を監視して波形をリアルタイム更新
    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        currentPosition = position;
        _updateWaveform();
      });
    });

    // 🎯 duration を事前に取得
    Future.delayed(Duration(milliseconds: 500), () async {
      Duration? audioDuration = await _audioPlayer.getDuration();
      if (audioDuration != null) {
        setState(() {
          print("🎵 [initState] 音声の長さを取得: ${audioDuration.inMilliseconds} ms");
        });
      } else {
        print("⚠️ [initState] duration の取得に失敗しました。");
      }
    });
  }

  /// **📂 アセットから音声ファイルをコピー**
  Future<String> copyAssetToFile(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load("assets/$assetPath");
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File("${tempDir.path}/$assetPath");

      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      return file.path;
    } catch (e) {
      print("⚠️ ファイルコピーに失敗しました: $e");
      return "";
    }
  }

  /// **🎵 音声ファイルをロードし波形データを取得**
  Future<void> _loadAudio() async {
    setState(() {
      fullWaveform = [];
      currentWaveform = [];
    });

    final String copiedFilePath = await copyAssetToFile("mount_fuji.mp3");
    if (copiedFilePath.isEmpty) {
      print("⚠️ 音声ファイルのコピーに失敗しました");
      return;
    }

    setState(() {
      filePath = copiedFilePath;
    });

    fullWaveform = await extractWaveform(File(filePath!));

    setState(() {
      currentWaveform = List.filled(50, 0.0); // 🎯 初期の波形
    });

    print("🎵 fullWaveform の長さ: ${fullWaveform.length}");
  }

  /// **📊 波形データを抽出**
  Future<List<double>> extractWaveform(File file) async {
    print("📊 extractWaveform() が呼ばれた！ 読み込むファイル: ${file.path}");

    final List<double> amplitudes = [];

    try {
      final Uint8List data = await file.readAsBytes();
      print("✅ ファイル読み込み成功！ データサイズ: ${data.length}");

      int step = (data.length ~/ 500).clamp(1, 10); // 🎯 分割数を調整

      for (int i = 0; i < data.length; i += step) {
        double normalizedValue = (data[i] / 255.0); // 🎯 0.0 〜 1.0 に正規化
        amplitudes.add(normalizedValue);
      }

      print("📊 取得した波形データのサンプル: ${amplitudes.take(10).toList()}");
    } catch (e) {
      print("⚠️ 波形データの解析に失敗しました: $e");
      return [];
    }

    return amplitudes;
  }

  /// **🔄 現在の再生位置に合わせて波形を更新**
  Future<void> _updateWaveform() async {
    if (fullWaveform.isEmpty) {
      print("⚠️ _updateWaveform() がスキップされました: fullWaveform が空");
      return;
    }

    Duration? audioDuration = await _audioPlayer.getDuration();
    if (audioDuration == null) {
      print("⚠️ _updateWaveform() がスキップされました: duration がまだ取得できていません");
      return;
    }

    final int totalSamples = fullWaveform.length;
    final int totalDurationMs = audioDuration.inMilliseconds;
    final int currentMs = currentPosition.inMilliseconds;

    if (totalDurationMs == 0) {
      print("⚠️ duration が 0 なので波形を更新できません");
      return;
    }

    // 🎯 波形の更新頻度（50msごと）
    const int updateIntervalMs = 50;
    final int numSamplesPerUpdate =
        (totalSamples / (totalDurationMs / updateIntervalMs)).toInt();

    final int startIndex = (currentMs / totalDurationMs * totalSamples)
        .clamp(0, totalSamples - numSamplesPerUpdate)
        .toInt();
    final int endIndex =
        (startIndex + numSamplesPerUpdate).clamp(0, totalSamples);

    print(
        "🔄 波形更新: startIndex=$startIndex, endIndex=$endIndex, totalSamples=$totalSamples");

    setState(() {
      currentWaveform = fullWaveform.sublist(startIndex, endIndex);
    });
  }

  /// **🎵 音声を再生・停止**
  void _toggleAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (filePath == null) {
        print("⚠️ ファイルがロードされていません");
        return;
      }

      try {
        await _audioPlayer.setSourceDeviceFile(filePath!);
        await _audioPlayer.resume();

        // 🎯 duration の取得を確実に行うために 500ms 待機
        await Future.delayed(Duration(milliseconds: 500));
        Duration? audioDuration = await _audioPlayer.getDuration();

        if (audioDuration != null) {
          setState(() {
            print("🎵 音声の長さを取得: ${audioDuration.inMilliseconds} ms");
          });
        } else {
          print("⚠️ duration の取得に失敗しました。");
        }

        print("🎵 音声再生成功");
      } catch (e) {
        print("⚠️ 音声再生エラー: $e");
      }
    }

    setState(() {
      isPlaying = !isPlaying;
    });
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
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              size: Size.fromHeight(100),
              painter: AudioWavePainter(
                amplitudes: currentWaveform,
                heightFactor: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
