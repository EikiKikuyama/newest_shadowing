import 'package:flutter/material.dart';
import 'services/text_to_speech_service.dart';

class TtsDemoPage extends StatefulWidget {
  const TtsDemoPage({super.key});

  @override
  TtsDemoPageState createState() => TtsDemoPageState();
}

class TtsDemoPageState extends State<TtsDemoPage> {
  final TextEditingController _controller = TextEditingController();
  final TextToSpeechService _ttsService = TextToSpeechService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TTS Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: '読み上げるテキストを入力してください'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _ttsService.synthesizeAndPlay(_controller.text);
              },
              child: Text('再生'),
            ),
          ],
        ),
      ),
    );
  }
}
