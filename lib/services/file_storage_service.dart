import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/recording.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

class FileStorageService {
  // `recordingsDir` を適切に定義する
  Future<String> getRecordingsDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/recordings";
    final dir = Directory(path);

    if (!await dir.exists()) {
      _logger.w("⚠️ recordings フォルダが見つかりません。作成します...");
      await dir.create(recursive: true);
      _logger.i("✅ recordings フォルダ作成成功: $path");
    } else {
      _logger.i("✅ recordings フォルダがすでに存在: $path");
    }

    return path;
  }

  // 🎯 録音ファイル一覧を取得するメソッド
  Future<List<Recording>> loadRecordings() async {
    final path = await getRecordingsDir(); // ここを修正！
    final dir = Directory(path);

    if (!await dir.exists()) {
      _logger.w("⚠️ recordings フォルダが存在しないため、空リストを返します。");
      return [];
    }

    final List<FileSystemEntity> files = dir.listSync();
    List<Recording> recordings = files
        .whereType<File>()
        .where((file) => file.path.endsWith('.m4a'))
        .map((file) {
      final stat = file.statSync();
      return Recording(
        filePath: file.path,
        createdAt: stat.modified, // 🎯 作成日時を取得
      );
    }).toList();

    recordings
        .sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 🎯 新しい順にソート

    _logger.d("📂 読み込まれた録音リスト: ${recordings.length} 件");
    return recordings;
  }

  Future<void> deleteRecording(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      _logger.i("🗑️ 削除成功: $filePath");
    }
  }
}
