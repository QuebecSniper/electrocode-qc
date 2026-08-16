import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  Future<String?> pickAndRecognize() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    if (picked == null || picked.files.single.path == null) return null;
    final path = picked.files.single.path!;
    if (path.toLowerCase().endsWith('.pdf')) {
      return extractPdfText(File(path));
    }
    try {
      final input = InputImage.fromFile(File(path));
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await recognizer.processImage(input);
      await recognizer.close();
      return result.text;
    } catch (e) {
      return 'OCR indisponible ($e). Saisir les données manuellement.';
    }
  }

  /// Extraction hors-ligne du calque texte (y compris flux FlateDecode).
  static String extractPdfText(File file) {
    final bytes = file.readAsBytesSync();
    final collected = StringBuffer(latin1.decode(bytes, allowInvalid: true));
    final raw = collected.toString();
    final streamRe = RegExp(r'stream\r?\n([\s\S]*?)endstream');
    for (final m in streamRe.allMatches(raw)) {
      final payload = latin1.encode(m.group(1)!);
      for (final decoded in _tryInflate(payload)) {
        collected.write('\n');
        collected.write(latin1.decode(decoded, allowInvalid: true));
      }
    }
    final text = _stringsFromPdf(collected.toString());
    if (text.length < 8) {
      return '[PDF local : ${file.path}]\n'
          'Aucun calque texte exploitable. Prenez une photo du plan pour l\'OCR, '
          'ou saisissez les charges manuellement.';
    }
    return text;
  }

  static Iterable<List<int>> _tryInflate(List<int> payload) sync* {
    try {
      yield zlib.decode(payload);
      return;
    } catch (_) {}
    try {
      yield ZLibDecoder(raw: true).convert(payload);
    } catch (_) {}
  }

  static String _stringsFromPdf(String raw) {
    final buffer = StringBuffer();
    final paren = RegExp(r'\((?:\\.|[^\\)])*\)');
    for (final m in paren.allMatches(raw)) {
      var s = m.group(0)!;
      s = s.substring(1, s.length - 1);
      s = s
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\r', '')
          .replaceAll(r'\t', ' ')
          .replaceAll(r'\(', '(')
          .replaceAll(r'\)', ')')
          .replaceAll(r'\\', r'\');
      if (RegExp(r'[A-Za-zÀ-ÿ0-9]').hasMatch(s)) {
        buffer.write(s);
        buffer.write(' ');
      }
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
