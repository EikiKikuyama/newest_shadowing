import 'package:flutter/material.dart';
import 'package:newest_shadowing_app/services/audio_recorder_service.dart';
import 'package:logger/logger.dart'; // ✅ ロガーを追加

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  RecorderScreenState createState() => RecorderScreenState();
}

class RecorderScreenState extends State<RecorderScreen> {
  final AudioRecorderService _recorderService = AudioRecorderService();
  final Logger _logger = Logger(); // ✅ Logger を作成
  bool _isRecording = false;

  Future<void> _toggleRecording() async {
    _logger.d("ボタンが押された！ 現在の録音状態: $_isRecording");

    if (_isRecording) {
      await _recorderService.stopRecording();
      _logger.i("録音を停止しました");
    } else {
      await _recorderService.startRecording();
      _logger.i("録音を開始しました");
    }

    setState(() {
      _isRecording = !_isRecording;
    });

    _logger.d("状態更新後の録音状態: $_isRecording");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recorder')),
      body: Center(
        child: ElevatedButton(
          onPressed: _toggleRecording,
          child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
        ),
      ),
    );
  }
}
