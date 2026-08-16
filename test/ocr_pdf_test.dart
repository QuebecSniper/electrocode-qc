import 'dart:convert';
import 'dart:io';

import 'package:electrocode_qc/services/ocr_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('electrocode_pdf');
  });

  tearDown(() {
    dir.deleteSync(recursive: true);
  });

  test('extrait le calque texte d\'un PDF numérique', () {
    const pdf = '%PDF-1.1\n'
        '1 0 obj<< /Length 52 >>stream\n'
        'BT /F1 12 Tf 10 100 Td (Bungalow 65 m2 service 100 A) Tj ET\n'
        'endstream\nendobj\n';
    final file = File('${dir.path}/plan.pdf')..writeAsStringSync(pdf);
    final text = OcrService.extractPdfText(file);
    expect(text.toLowerCase(), contains('bungalow'));
    expect(text, contains('100'));
  });

  test('extrait un tableau TJ', () {
    const pdf = '%PDF-1.1\nstream\n'
        'BT [(Studio ) -10 (65 m2)] TJ ET\n'
        'endstream\n';
    final file = File('${dir.path}/tj.pdf')..writeAsStringSync(pdf);
    final r = OcrService.extractPdfFile(file);
    expect(r.hasText, isTrue);
    expect(r.text.toLowerCase(), contains('studio'));
    expect(r.text, contains('65'));
  });

  test('extrait un flux FlateDecode', () {
    final inner = utf8.encode('BT (Chauffage 15000 W) Tj ET');
    final compressed = zlib.encode(inner);
    final header = utf8.encode(
      '%PDF-1.4\n1 0 obj<< /Filter /FlateDecode >>stream\n',
    );
    final tail = utf8.encode('\nendstream\nendobj\n');
    final bytes = <int>[...header, ...compressed, ...tail];
    final file = File('${dir.path}/flate.pdf')..writeAsBytesSync(bytes);
    final r = OcrService.extractPdfFile(file);
    expect(r.status, ExtractStatus.success);
    expect(r.text, contains('15000'));
    expect(r.text.toLowerCase(), contains('chauffage'));
  });

  test('PDF sans calque → scannedPdf, pas de faux texte', () {
    const pdf = '%PDF-1.1\n1 0 obj<< /Type /XObject >>stream\n'
        '\x00\x01\x02\x03\x04\x05\x06\x07\n'
        'endstream\nendobj\n';
    final file = File('${dir.path}/scan.pdf')..writeAsStringSync(pdf);
    final r = OcrService.extractPdfFile(file);
    expect(r.hasText, isFalse);
    expect(r.status, ExtractStatus.scannedPdf);
    expect(r.userMessage.toLowerCase(), contains('photo'));
    expect(r.userMessage.toLowerCase(), contains('sais'));
  });

  test('image vide → message de saisie manuelle', () async {
    final file = File('${dir.path}/empty.jpg')..writeAsBytesSync([]);
    final r = await OcrService().recognizeImageFile(file);
    expect(r.hasText, isFalse);
    expect(r.status, ExtractStatus.empty);
    expect(r.userMessage.toLowerCase(), contains('main'));
  });
}
