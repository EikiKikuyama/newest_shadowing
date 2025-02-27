import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  AudioPlayerScreenState createState() => AudioPlayerScreenState();
}

class AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  void _playAudio() async {
    print("🎵 音声再生開始！");
    await _audioPlayer.play(AssetSource("mount_fuji.mp3"));
    setState(() => isPlaying = true);
  }

  void _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() => isPlaying = false);
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() => isPlaying = false);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("見本音声の再生")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isPlaying ? _pauseAudio : _playAudio,
              child: Text(isPlaying ? "⏸ 一時停止" : "▶ 再生"),
            ),
            ElevatedButton(
              onPressed: _stopAudio,
              child: Text("⏹ 停止"),
            ),
          ],
        ),
      ),
    );
  }
}
