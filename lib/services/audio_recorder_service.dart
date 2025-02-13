import 'package:record/record.dart';
import 'file_storage_service.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder(); // ✅ AudioRecorder に変更
  final FileStorageService _fileStorageService = FileStorageService();

  Future<void> startRecording() async {
    final permission = await _recorder.hasPermission(); // ✅ 最新APIに対応
    if (!permission) {
      throw Exception("録音の許可がありません");
    }

    final directory = await _fileStorageService.recordingsDir;
    final filePath =
        '$directory/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // ✅ AudioRecorderConfig を使用
    await _recorder.start(
      const RecordConfig(
          encoder: AudioEncoder.aacLc, sampleRate: 44100, bitRate: 128000),
      path: filePath,
    );
  }

  Future<void> stopRecording() async {
    await _recorder.stop();
  }
}
