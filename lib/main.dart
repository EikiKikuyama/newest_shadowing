import 'package:flutter/material.dart';
import 'screens/recorder_screen.dart';
import 'screens/recordings_list_screen.dart';

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
      home: RecorderScreen(), // 録音画面を最初に表示
      routes: {
        '/recordings': (context) => const RecordingsListScreen(), // 録音リスト画面
      },
    );
  }
}
