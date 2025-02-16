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
    setState(() {
      _recordings = recordings;
    });
  }

  void _deleteRecording(String filePath) async {
    await _fileStorageService.deleteRecording(filePath);
    _loadRecordings();
  }

  void _playRecording(String filePath) async {
    await _audioPlayer.play(DeviceFileSource(filePath)); // 🎯 再生処理
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
            onTap: () => _playRecording(recording.filePath), // 🎯 追加（タップで再生）
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteRecording(recording.filePath),
            ),
          );
        },
      ),
    );
  }
}
