import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playRecording(String filePath) async {
    await _audioPlayer.play(DeviceFileSource(filePath));
  }
}
