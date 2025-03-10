import 'package:flutter/material.dart';
import 'package:newest_shadowing_app/screens/audio_waveform_screen.dart';

class RecorderScreen extends StatelessWidget {
  const RecorderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("録音画面")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AudioWaveformScreen()),
                );
              },
              child: const Text("録音開始"),
            ),
          ],
        ),
      ),
    );
  }
}
