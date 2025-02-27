import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();
  String? _filePath;
  String? recordedFilePath;
  bool isRecording = false;
  StreamSubscription<RecordState>? _stateSubscription;
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

      log("🎤 録音開始準備: $_filePath");

      // ✅ 録音開始を非同期処理にして UI をブロックしない
      _recorder
          .start(
        RecordConfig(encoder: AudioEncoder.aacLc),
        path: _filePath!,
      )
          .then((_) {
        log("🎤 録音開始: $_filePath");
        isRecording = true;
        recordedFilePath = null;

        // ✅ `onStateChanged` で録音の状態を監視
        _stateSubscription?.cancel();
        _stateSubscription = _recorder.onStateChanged().listen((state) {
          if (state == RecordState.record) {
            log("🎤 録音中...");
          }
        });

        // ✅ `onAmplitudeChanged()` の修正（非同期で処理）
        Future.delayed(const Duration(milliseconds: 500), () {
          _amplitudeSubscription?.cancel();
          _amplitudeSubscription = _recorder
              .onAmplitudeChanged(const Duration(milliseconds: 100))
              .listen((event) {
            double amplitude = event.current;

            // 🎯 負の値を正規化（0-1の範囲に変換）
            double normalizedAmplitude = (amplitude + 160) / 160;

            log("📊 振幅データ受信: ${event.current} → 正規化: $normalizedAmplitude");
            _amplitudeController.add(normalizedAmplitude);
          }, onError: (e) {
            log("❌ 振幅データエラー: $e");
          });
        });
      }).catchError((e) {
        log("❌ 録音開始エラー: $e");
      });
    } catch (e) {
      log("❌ 録音開始エラー（try-catch）: $e");
    }
  }

  /// **🛑 録音停止**
  Future<void> stopRecording() async {
    try {
      String? filePath = await _recorder.stop();
      log("🎤 録音停止: $filePath");

      isRecording = false;
      if (filePath != null) {
        recordedFilePath = filePath;
      }

      // ✅ ストリーム購読解除
      await _stateSubscription?.cancel();
      _stateSubscription = null;
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
    } catch (e) {
      log("❌ 録音停止エラー: $e");
    }
  }

  /// **🎤 ストリームを閉じる**
  void dispose() {
    _stateSubscription?.cancel();
    _amplitudeSubscription?.cancel();
    _amplitudeController.close();
  }
}
