import 'package:flutter/material.dart';
import 'package:newest_shadowing_app/services/audio_recorder_service.dart'; // ✅ 追加

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  RecorderScreenState createState() => RecorderScreenState();
}

class RecorderScreenState extends State<RecorderScreen> {
  final AudioRecorderService _recorderService =
      AudioRecorderService(); // ✅ 修正後もこのままでOK
  bool _isRecording = false;

  Future<void> _toggleRecording() async {
    // ✅ async を追加
    if (_isRecording) {
      await _recorderService.stopRecording();
    } else {
      await _recorderService.startRecording();
    }
    setState(() {
      _isRecording = !_isRecording;
    });
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
