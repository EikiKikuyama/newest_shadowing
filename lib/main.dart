import 'package:flutter/material.dart';
import 'screens/audio_waveform_screen.dart'; // 修正: 正しいファイルをimport

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recorder App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      routes: {
        '/waveform': (context) => const AudioWaveformScreen(), // 修正: 正しくルートを設定
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ホーム")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/waveform');
          },
          child: const Text("📊 波形表示画面へ"),
        ),
      ),
    );
  }
}
