import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _ready = false;

  Future<bool> init() async {
    _ready = await _speech.initialize();
    return _ready;
  }

  Future<String?> listenFrCa() async {
    if (!_ready) {
      final ok = await init();
      if (!ok) return null;
    }
    var buffer = '';
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'fr_CA'),
      onResult: (r) {
        buffer = r.recognizedWords;
      },
    );
    await Future<void>.delayed(const Duration(seconds: 6));
    await _speech.stop();
    return buffer.trim().isEmpty ? null : buffer.trim();
  }
}
