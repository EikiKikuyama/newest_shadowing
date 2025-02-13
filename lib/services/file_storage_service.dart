import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/recording.dart';

class FileStorageService {
  // ✅ ここに _recordingsDir の getter を追加！
  Future<String> get recordingsDir async {
    final directory = await getApplicationDocumentsDirectory();
    final recordingsPath = '${directory.path}/recordings';
    final dir = Directory(recordingsPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return recordingsPath;
  }

  Future<List<Recording>> loadRecordings() async {
    final dirPath = await recordingsDir;
    final dir = Directory(dirPath);
    final files = dir.listSync().whereType<File>().toList();

    return files.map((file) {
      return Recording(filePath: file.path, createdAt: file.lastModifiedSync());
    }).toList();
  }

  Future<void> deleteRecording(String filePath) async {
    final file = File(filePath);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
