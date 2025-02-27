import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // 🎯 再生用パッケージ
import '../services/file_storage_service.dart';
import '../models/recording.dart';

class RecordingsListScreen extends StatefulWidget {
  const RecordingsListScreen({super.key});

  @override
  RecordingsListScreenState createState() => RecordingsListScreenState();
}

class RecordingsListScreenState extends State<RecordingsListScreen> {
  final FileStorageService _fileStorageService = FileStorageService();
  final AudioPlayer _audioPlayer = AudioPlayer(); // 🎯 追加
  List<Recording> _recordings = [];

  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }

  Future<void> _loadRecordings() async {
    final recordings = await _fileStorageService.loadRecordings();

    if (!mounted) return; // 🎯 context が有効か確認

    setState(() {
      _recordings = recordings;
    });
  }

  void _deleteRecording(String filePath) async {
    await _fileStorageService.deleteRecording(filePath);

    if (!mounted) return; // 🎯 context が有効か確認

    setState(() {
      _recordings.removeWhere((recording) => recording.filePath == filePath);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('録音を削除しました')),
    );
  }

  void _playRecording(String filePath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(filePath));

      if (!mounted) return; // 🎯 画面がまだ有効か確認
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('再生を開始しました')),
      );
    } catch (e) {
      if (!mounted) return; // 🎯 画面がまだ有効か確認
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('再生エラー: $e')),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // 🎯 リソース解放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('録音リスト')),
      body: ListView.builder(
        itemCount: _recordings.length,
        itemBuilder: (context, index) {
          final recording = _recordings[index];
          return ListTile(
            title: Text('録音 ${index + 1}'),
            subtitle: Text(recording.createdAt.toString()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow), // 🎯 再生ボタン
                  onPressed: () => _playRecording(recording.filePath),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteRecording(recording.filePath),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
