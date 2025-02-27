import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class TextToSpeechService {
  final String _apiKey = dotenv.env['GOOGLE_TTS_API_KEY'] ?? '';

  Future<void> synthesizeAndPlay(String text) async {
    final String url =
        'https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey';

    final Map<String, dynamic> requestBody = {
      'input': {'text': text},
      'voice': {
        'languageCode': 'en-US',
        'ssmlGender': 'NEUTRAL',
      },
      'audioConfig': {'audioEncoding': 'MP3'},
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String audioContent = responseData['audioContent'];
        final List<int> audioBytes = base64.decode(audioContent);
        final Uint8List audioData = Uint8List.fromList(audioBytes);

        final AudioPlayer audioPlayer = AudioPlayer();
        // audioplayers の最新APIでは playBytes() はなく、代わりに play() に BytesSource を渡します
        await audioPlayer.play(BytesSource(audioData));
      } else {
        print('TTS API error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Exception in TTS service: $e');
    }
  }
}
