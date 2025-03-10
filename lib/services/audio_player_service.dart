import 'dart:io';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? filePath;

  Future<String> copyAssetToFile(String assetPath) async {
    final ByteData data = await rootBundle.load("assets/$assetPath");
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File("${tempDir.path}/$assetPath");
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file.path;
  }

  Future<void> loadAudio() async {
    filePath = await copyAssetToFile("mount_fuji.mp3");
  }

  Future<void> playAudio() async {
    if (filePath == null) return;
    await _audioPlayer.setSourceDeviceFile(filePath!);
    await _audioPlayer.resume();
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }
}
