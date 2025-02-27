import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_recorder_service.dart';
import '../services/audio_wave_painter.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  RecorderScreenState createState() => RecorderScreenState();
}

class RecorderScreenState extends State<RecorderScreen> {
  late AudioRecorderService _recorderService;
  late StreamSubscription<double> _amplitudeSubscription;
  final List<double> _amplitudeHistory = List.filled(50, 0.0, growable: true);
  bool isRecording = false;
  double heightFactor = 1.0;

  @override
  void initState() {
    super.initState();
    _recorderService = AudioRecorderService();

    _amplitudeSubscription =
        _recorderService.amplitudeStream.listen((amplitude) {
      if (mounted) {
        setState(() {
          if (_amplitudeHistory.length >= 50) {
            _amplitudeHistory.removeAt(0);
          }
          _amplitudeHistory.add(amplitude.abs()); // 🎯 正の値に変換
        });
      }
    });
  }

  @override
  void dispose() {
    _amplitudeSubscription.cancel();
    super.dispose();
  }

  void startRecording() async {
    await _recorderService.startRecording();
    setState(() {
      isRecording = true;
    });
  }

  void stopRecording() async {
    await _recorderService.stopRecording();
    setState(() {
      isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recorder')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(
              painter: AudioWavePainter(
                amplitudes: _amplitudeHistory,
                heightFactor: heightFactor,
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              isRecording ? stopRecording() : startRecording();
            },
            child: Icon(isRecording ? Icons.stop : Icons.mic),
          ),
        ],
      ),
    );
  }
}
