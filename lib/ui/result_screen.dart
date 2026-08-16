import 'dart:convert';

import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:flutter/material.dart';

import '../services/export_service.dart';
import 'theme.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final CalculationResult result;

  Color get _statusColor {
    switch (result.complianceStatus) {
      case ComplianceStatus.conforme:
        return Colors.green.shade700;
      case ComplianceStatus.nonConforme:
        return Colors.red.shade700;
      case ComplianceStatus.questionsEnAttente:
        return Colors.orange.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final export = ExportService();
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(result.projectName),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Synthèse'),
              Tab(text: 'Calculs'),
              Tab(text: 'Matériaux'),
              Tab(text: 'Code'),
              Tab(text: 'JSON'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: _statusColor.withValues(alpha: 0.15),
                  child: Text(
                    result.complianceStatus.json.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(ElectroCode.disclaimer, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                Text('Code ${ElectroCode.codeVersion} · app ${ElectroCode.appVersion}'),
                Text('Service : ${result.service['selected_amps']} A'),
                Text('Panneau : ${result.mainPanel['bus_amps']} A'),
                ...result.warnings.map((w) => ListTile(
                      leading: const Icon(Icons.warning_amber),
                      title: Text(w),
                      dense: true,
                    )),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _block('Service', result.service),
                _block('Panneau', result.mainPanel),
                _block('Sous-panneaux', {'items': result.subPanels}),
                _block('Disjoncteurs', {'items': result.breakers}),
                _block('Conducteurs', {'items': result.conductors}),
                _block('Canalisations', {'items': result.conduits}),
                _block('Terre', result.grounding),
                _block('Chute de tension', result.voltageDrop),
              ],
            ),
            ListView(
              children: result.materials
                  .map(
                    (m) => ListTile(
                      title: Text(m.description),
                      subtitle: Text(
                        '${m.category} · ${m.quantity} ${m.unit}\n${m.notes}',
                      ),
                      isThreeLine: true,
                    ),
                  )
                  .toList(),
            ),
            ListView(
              children: result.codeReferences
                  .map(
                    (r) => ListTile(
                      title: Text('${r.rule}  ${r.table}'),
                      subtitle: Text(r.description),
                    ),
                  )
                  .toList(),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(result.toJson()),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => export.shareJson(result),
                    icon: const Icon(Icons.data_object),
                    label: const Text('JSON'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: ElectroTheme.navy,
                    ),
                    onPressed: () => export.sharePdf(result),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _block(String title, Map<String, dynamic> data) {
    return ExpansionTile(
      title: Text(title),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SelectableText(
            const JsonEncoder.withIndent('  ').convert(data),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}
