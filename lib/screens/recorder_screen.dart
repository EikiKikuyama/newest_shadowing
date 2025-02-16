import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_recorder_service.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  RecorderScreenState createState() => RecorderScreenState();
}

class RecorderScreenState extends State<RecorderScreen> {
  late AudioRecorderService _recorderService;
  late StreamSubscription<double> _amplitudeSubscription;
  final List<double> _amplitudeHistory = List.filled(50, 0.0);

  @override
  void initState() {
    super.initState();
    _recorderService = AudioRecorderService();

    // `getAmplitudeStream()` を `amplitudeStream` に修正
    _amplitudeSubscription =
        _recorderService.amplitudeStream.listen((amplitude) {
      if (mounted) {
        setState(() {
          _amplitudeHistory.removeAt(0);
          _amplitudeHistory.add(amplitude);
        });
      }
    });
  }

  @override
  void dispose() {
    _amplitudeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recorder'),
      ),
      body: Center(
        child: Text('Amplitude: ${_amplitudeHistory.last}'),
      ),
    );
  }
}
