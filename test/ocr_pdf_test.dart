import 'dart:io';

import 'package:electrocode_qc/services/ocr_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extrait le calque texte d\'un PDF numérique', () {
    const pdf = '%PDF-1.1\n'
        '1 0 obj<< /Length 52 >>stream\n'
        'BT /F1 12 Tf 10 100 Td (Bungalow 65 m2 service 100 A) Tj ET\n'
        'endstream\nendobj\n';
    final dir = Directory.systemTemp.createTempSync('electrocode_pdf');
    final file = File('${dir.path}/plan.pdf');
    file.writeAsStringSync(pdf);
    final text = OcrService.extractPdfText(file);
    expect(text.toLowerCase(), contains('bungalow'));
    expect(text, contains('100'));
    dir.deleteSync(recursive: true);
  });
}
