import 'dart:convert';
import 'dart:io';

import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  Future<void> shareJson(CalculationResult result) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/electrocode_qc.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(result.toJson()),
    );
    await Share.shareXFiles([XFile(file.path)], text: result.projectName);
  }

  Future<void> sharePdf(CalculationResult result) async {
    final doc = pw.Document();
    final headerStyle = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold);
    final cell = pw.TextStyle(fontSize: 9);

    pw.Widget table(List<String> headers, List<List<String>> rows) {
      return pw.TableHelper.fromTextArray(
        headers: headers,
        data: rows,
        headerStyle: headerStyle,
        cellStyle: cell,
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
        cellAlignment: pw.Alignment.centerLeft,
        border: pw.TableBorder.all(color: PdfColors.blueGrey300, width: 0.4),
      );
    }

    final service = result.service;
    final demand = (service['demand'] as Map?) ?? {};
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'ÉlectroCode QC — Rapport de dimensionnement',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text('Projet : ${result.projectName}'),
          pw.Text(
            'Code : ${ElectroCode.codeVersion}  |  App : ${ElectroCode.appVersion}  |  '
            'Statut : ${result.complianceStatus.json}',
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            ElectroCode.disclaimer,
            style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Service et demande', style: headerStyle),
          table(
            const ['Champ', 'Valeur'],
            [
              ['Méthode', '${demand['method'] ?? ''}'],
              ['Charge calculée (A)', '${demand['calculated_amps'] ?? ''}'],
              ['Minimum 8-200 (A)', '${service['minimum_amps_8_200'] ?? ''}'],
              ['Service retenu (A)', '${service['selected_amps'] ?? ''}'],
              [
                'Conducteur',
                '${service['ungrounded_conductor'] ?? ''} ${service['material'] ?? ''}',
              ],
              [
                'Calibre imposé',
                service['conductor_forced'] == true ? 'oui' : 'non',
              ],
              ['Tableau ampacité', '${service['ampacity_table'] ?? ''}'],
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text('Conducteurs', style: headerStyle),
          table(
            const ['Rôle', 'Calibre', 'Mat.', 'Req. A', 'Adm. A'],
            result.conductors
                .map(
                  (c) => [
                    '${c['role']}',
                    '${c['size_awg_kcmil']}',
                    '${c['material']}',
                    '${c['required_amps']}',
                    '${c['allowable_amps']}',
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Matériaux', style: headerStyle),
          table(
            const ['Catégorie', 'Description', 'Qté', 'Unité'],
            result.materials
                .map(
                  (m) => [
                    m.category,
                    m.description,
                    '${m.quantity}',
                    m.unit,
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Références Code', style: headerStyle),
          table(
            const ['Article', 'Tableau', 'Description'],
            result.codeReferences
                .map((r) => [r.rule, r.table, r.description])
                .toList(),
          ),
          if (result.warnings.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text('Avertissements', style: headerStyle),
            ...result.warnings.map((w) => pw.Bullet(text: w)),
          ],
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }
}
