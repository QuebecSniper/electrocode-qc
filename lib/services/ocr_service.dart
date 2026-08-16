import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

enum ExtractStatus {
  success,
  cancelled,
  empty,
  scannedPdf,
  error,
}

class ExtractResult {
  const ExtractResult({
    required this.status,
    this.text = '',
    required this.userMessage,
  });

  final ExtractStatus status;
  final String text;
  final String userMessage;

  bool get hasText =>
      status == ExtractStatus.success && text.trim().isNotEmpty;

  static const cancelled = ExtractResult(
    status: ExtractStatus.cancelled,
    userMessage: 'Import annulé.',
  );
}

/// OCR photo (ML Kit) + calque texte PDF. Hors-ligne. Pas de règles de calcul.
class OcrService {
  final ImagePicker _picker = ImagePicker();
  static const _minUseful = 8;
  static const _stopAfterChars = 2500;

  Future<ExtractResult> pickAndRecognize() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    if (picked == null || picked.files.single.path == null) {
      return ExtractResult.cancelled;
    }
    return recognizePath(picked.files.single.path!);
  }

  Future<ExtractResult> capturePhoto() async {
    try {
      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (shot == null) return ExtractResult.cancelled;
      return await recognizePath(shot.path);
    } catch (e) {
      return ExtractResult(
        status: ExtractStatus.error,
        userMessage:
            'Caméra indisponible ($e). Choisissez une photo du dossier, ou saisissez à la main.',
      );
    }
  }

  Future<ExtractResult> pickGalleryImage() async {
    try {
      final shot = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (shot == null) return ExtractResult.cancelled;
      return await recognizePath(shot.path);
    } catch (e) {
      return ExtractResult(
        status: ExtractStatus.error,
        userMessage:
            'Galerie indisponible ($e). Saisissez les charges à la main.',
      );
    }
  }

  Future<ExtractResult> recognizePath(String path) async {
    if (path.toLowerCase().endsWith('.pdf')) {
      return extractPdfFile(File(path));
    }
    return recognizeImageFile(File(path));
  }

  Future<ExtractResult> recognizeImageFile(File file) async {
    if (!file.existsSync() || file.lengthSync() == 0) {
      return const ExtractResult(
        status: ExtractStatus.empty,
        userMessage:
            'Fichier image vide. Reprenez la photo, ou saisissez à la main.',
      );
    }
    TextRecognizer? recognizer;
    try {
      recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await recognizer.processImage(InputImage.fromFile(file));
      final text = _clean(result.text);
      if (text.length < _minUseful) {
        return const ExtractResult(
          status: ExtractStatus.empty,
          userMessage:
              'Aucun texte lu sur la photo. Cadrez le cartouche / la liste de charges, plus de lumière, ou saisissez à la main.',
        );
      }
      return ExtractResult(
        status: ExtractStatus.success,
        text: text,
        userMessage: 'Texte lu sur la photo. Vérifiez les champs remplis.',
      );
    } catch (e) {
      return ExtractResult(
        status: ExtractStatus.error,
        userMessage:
            'OCR indisponible ($e). Saisissez les données manuellement.',
      );
    } finally {
      await recognizer?.close();
    }
  }

  static ExtractResult extractPdfFile(File file) {
    if (!file.existsSync()) {
      return const ExtractResult(
        status: ExtractStatus.error,
        userMessage: 'PDF introuvable. Saisissez à la main.',
      );
    }
    return extractPdfBytes(file.readAsBytesSync(), label: file.path);
  }

  /// Conservé pour les tests : texte brut, ou message d’échec PDF scanné.
  static String extractPdfText(File file) {
    final r = extractPdfFile(file);
    if (r.hasText) return r.text;
    return r.userMessage;
  }

  static ExtractResult extractPdfBytes(List<int> bytes, {String label = 'PDF'}) {
    if (bytes.length < 8) {
      return const ExtractResult(
        status: ExtractStatus.scannedPdf,
        userMessage:
            'PDF vide ou illisible. Photo du plan pour l’OCR, ou saisie manuelle.',
      );
    }
    final harvested = <String>[];
    void harvest(String raw) {
      if (_usefulLen(harvested) >= _stopAfterChars) return;
      harvested.addAll(_literalStrings(raw));
      harvested.addAll(_tjChunks(raw));
      harvested.addAll(_hexStrings(raw));
    }

    final asLatin = latin1.decode(bytes, allowInvalid: true);
    harvest(asLatin);

    final streamRe = RegExp(r'stream\r?\n([\s\S]*?)endstream');
    for (final m in streamRe.allMatches(asLatin)) {
      if (_usefulLen(harvested) >= _stopAfterChars) break;
      final payload = latin1.encode(m.group(1)!);
      if (payload.length > 1 * 1024 * 1024) continue;
      if (_looksLikeJpeg(payload) || _looksLikePng(payload)) continue;
      for (final decoded in _tryInflate(payload)) {
        harvest(latin1.decode(decoded, allowInvalid: true));
      }
    }

    final text = _clean(harvested.join(' '));
    if (text.length < _minUseful) {
      return ExtractResult(
        status: ExtractStatus.scannedPdf,
        userMessage:
            'Aucun calque texte dans ce PDF ($label). Prenez une photo du plan pour l’OCR, ou saisissez les charges à la main.',
      );
    }
    return ExtractResult(
      status: ExtractStatus.success,
      text: text,
      userMessage: 'Texte extrait du PDF. Vérifiez les champs remplis.',
    );
  }

  static int _usefulLen(List<String> parts) =>
      parts.fold<int>(0, (n, s) => n + s.length);

  static bool _looksLikeJpeg(List<int> b) =>
      b.length > 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF;

  static bool _looksLikePng(List<int> b) =>
      b.length > 8 &&
      b[0] == 0x89 &&
      b[1] == 0x50 &&
      b[2] == 0x4E &&
      b[3] == 0x47;

  static Iterable<List<int>> _tryInflate(List<int> payload) sync* {
    try {
      yield zlib.decode(payload);
      return;
    } catch (_) {}
    var start = 0;
    while (start < payload.length &&
        (payload[start] == 0x0A || payload[start] == 0x0D)) {
      start++;
    }
    if (start > 0 && start < payload.length) {
      try {
        yield zlib.decode(payload.sublist(start));
        return;
      } catch (_) {}
    }
    try {
      yield ZLibDecoder(raw: true).convert(
        start > 0 ? payload.sublist(start) : payload,
      );
    } catch (_) {}
  }

  static Iterable<String> _literalStrings(String raw) sync* {
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
      if (RegExp(r'[A-Za-zÀ-ÿ0-9]').hasMatch(s)) yield s;
    }
  }

  static Iterable<String> _tjChunks(String raw) sync* {
    final tj = RegExp(r'\[(.*?)\]\s*T[Jj]', dotAll: true);
    for (final m in tj.allMatches(raw)) {
      yield* _literalStrings(m.group(1)!);
    }
  }

  static Iterable<String> _hexStrings(String raw) sync* {
    final hex = RegExp(r'<([0-9A-Fa-f]{8,})>');
    for (final m in hex.allMatches(raw)) {
      final h = m.group(1)!;
      if (h.length.isOdd) continue;
      try {
        final bytes = <int>[];
        for (var i = 0; i < h.length; i += 2) {
          bytes.add(int.parse(h.substring(i, i + 2), radix: 16));
        }
        String decoded;
        if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
          decoded = _utf16Be(Uint8List.fromList(bytes.sublist(2)));
        } else if (bytes.every((b) => b == 0 || (b >= 32 && b < 127))) {
          decoded = latin1.decode(bytes, allowInvalid: true);
        } else if (bytes.length.isEven) {
          decoded = _utf16Be(Uint8List.fromList(bytes));
        } else {
          decoded = latin1.decode(bytes, allowInvalid: true);
        }
        if (RegExp(r'[A-Za-zÀ-ÿ0-9]').hasMatch(decoded)) yield decoded;
      } catch (_) {}
    }
  }

  static String _utf16Be(Uint8List bytes) {
    final codes = <int>[];
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      codes.add((bytes[i] << 8) | bytes[i + 1]);
    }
    return String.fromCharCodes(codes);
  }

  static String _clean(String raw) =>
      raw.replaceAll(RegExp(r'\s+'), ' ').trim();
}
