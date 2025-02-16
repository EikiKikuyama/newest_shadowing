import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderService {
  final Record _recorder = Record();
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();
  String? _filePath;
  String? recordedFilePath; // ✅ 追加: 録音ファイルのパスを保存
  bool isRecording = false; // ✅ 追加: 録音状態の管理
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  /// **📊 振幅データのストリームを取得**
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  /// **🎤 録音開始**
  Future<void> startRecording() async {
    try {
      final bool hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw Exception("録音の許可がありません");
      }

      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory("${directory.path}/recordings");
      if (!recordingsDir.existsSync()) {
        recordingsDir.createSync(recursive: true);
      }

      _filePath =
          "${recordingsDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a";

      await _recorder.start(
        RecordConfig(encoder: AudioEncoder.aacLc),
        path: _filePath!,
      );

      log("🎤 録音開始: $_filePath");

      // ✅ `setState()` で録音中の状態を更新
      isRecording = true;
      recordedFilePath = null;

      // ✅ `onProgress` を使用して振幅データを取得
      _amplitudeSubscription?.cancel();
      _amplitudeSubscription = _recorder.onProgress!.listen((event) {
        if (event != null) {
          double amplitude = event.decibels ?? -60.0; // dB値を取得（-60が無音）
          _amplitudeController.add(amplitude);
        }
      });
    } catch (e) {
      log("❌ 録音開始エラー: $e");
    }
  }

  /// **🛑 録音停止**
  Future<void> stopRecording() async {
    try {
      String? filePath = await _recorder.stop();
      log("🎤 録音停止: $filePath");

      // ✅ `setState()` で録音終了を更新
      isRecording = false;
      if (filePath != null) {
        recordedFilePath = filePath; // ✅ 取得したファイルパスを保存
      }

      // ✅ ストリーム購読解除
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
    } catch (e) {
      log("❌ 録音停止エラー: $e");
    }
  }

  /// **🎤 ストリームを閉じる**
  void dispose() {
    _amplitudeSubscription?.cancel();
    _amplitudeController.close();
  }
}
