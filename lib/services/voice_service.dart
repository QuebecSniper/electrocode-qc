import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

class VoiceResult {
  const VoiceResult({required this.ok, this.text, required this.message});

  final bool ok;
  final String? text;
  final String message;
}

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _ready = false;

  Future<bool> init() async {
    _ready = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _ready;
  }

  Future<VoiceResult> listenFrCa() async {
    if (!_ready) {
      final ok = await init();
      if (!ok) {
        return const VoiceResult(
          ok: false,
          message:
              'Dictée indisponible. Autorisez le micro, installez fr_CA (français Canada), ou saisissez à la main.',
        );
      }
    }
    var buffer = '';
    final done = Completer<void>();
    try {
      await _speech.listen(
        onResult: (r) {
          buffer = r.recognizedWords;
          if (r.finalResult && !done.isCompleted) done.complete();
        },
        listenOptions: SpeechListenOptions(
          localeId: 'fr_CA',
          listenFor: const Duration(seconds: 8),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          listenMode: ListenMode.dictation,
          cancelOnError: true,
        ),
      );
      await Future.any([
        done.future,
        Future<void>.delayed(const Duration(seconds: 9)),
      ]);
    } catch (e) {
      return VoiceResult(
        ok: false,
        message: 'Dictée interrompue ($e). Saisissez à la main.',
      );
    } finally {
      await _speech.stop();
    }
    final text = buffer.trim();
    if (text.isEmpty) {
      return const VoiceResult(
        ok: false,
        message:
            'Aucun mot reconnu. Parlez plus près, vérifiez fr_CA, ou saisissez à la main.',
      );
    }
    return VoiceResult(
      ok: true,
      text: text,
      message: 'Dictée ajoutée. Vérifiez les champs remplis.',
    );
  }
}
