import 'dart:convert';

import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/export_service.dart';
import 'theme.dart';
import 'widgets/field_ui.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final CalculationResult result;

  String get _serviceAmps => '${result.service['selected_amps'] ?? '—'} A';

  String get _conductor {
    final size = result.service['ungrounded_conductor'] ??
        (result.conductors.isNotEmpty ? result.conductors.first['size_awg_kcmil'] : null);
    final mat = result.conductors.isNotEmpty
        ? result.conductors.first['material']
        : '';
    if (size == null) return '—';
    return '#$size ${mat ?? ''}'.trim();
  }

  String get _panel => '${result.mainPanel['bus_amps'] ?? '—'} A';

  String get _vd {
    final v = result.voltageDrop['worst_segment_percent'];
    if (v == null) return '—';
    return '$v %';
  }

  String _str(dynamic v) => v == null ? '—' : '$v';

  @override
  Widget build(BuildContext context) {
    final export = ExportService();
    final demand = result.service['demand'];
    final calcAmps = demand is Map ? demand['calculated_amps'] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(result.projectName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'json') {
                await export.shareJson(result);
              } else if (v == 'copy') {
                await Clipboard.setData(
                  ClipboardData(
                    text: const JsonEncoder.withIndent('  ').convert(result.toJson()),
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('JSON copié.')),
                  );
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'json', child: Text('Partager le JSON')),
              PopupMenuItem(value: 'copy', child: Text('Copier le JSON')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const StepHeader(current: 3, total: 3),
          StatusBanner(
            status: result.complianceStatus,
            subtitle: result.complianceStatus == ComplianceStatus.nonConforme
                ? 'Lire les avertissements ci-dessous avant de commander le matériel.'
                : 'Vérifier sur C22.10:26 avant installation.',
          ),
          const SizedBox(height: 8),
          Text(
            ElectroCode.disclaimer,
            style: const TextStyle(fontSize: 12, color: ElectroTheme.muted, height: 1.3),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              MetricTile(label: 'Service', value: _serviceAmps),
              const SizedBox(width: 8),
              MetricTile(label: 'Conducteur', value: _conductor),
              const SizedBox(width: 8),
              MetricTile(label: 'Panneau', value: _panel),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              MetricTile(
                label: 'Demande',
                value: calcAmps == null ? '—' : '$calcAmps A',
              ),
              const SizedBox(width: 8),
              MetricTile(label: 'Chute max.', value: _vd, hint: 'limite 3 % / 5 %'),
            ],
          ),
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Avertissements', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...result.warnings.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ElectroTheme.wait.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber, color: ElectroTheme.wait),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(w, style: const TextStyle(fontSize: 16, height: 1.3)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SectionCard(
            title: 'Liste de matériel',
            child: Column(
              children: [
                for (var i = 0; i < result.materials.length; i++) ...[
                  if (i > 0) const Divider(height: 20),
                  _material(result.materials[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Terre et chute de tension',
            child: Column(
              children: [
                KvRow(label: 'Électrode', value: _str(result.grounding['electrode'])),
                KvRow(
                  label: 'GEC (Cu)',
                  value: '#${_str(result.grounding['grounding_electrode_conductor_cu'])}',
                ),
                KvRow(
                  label: 'Liaison (Cu)',
                  value: '#${_str(result.grounding['equipment_bonding_conductor_cu'])}',
                ),
                KvRow(label: 'Chute max.', value: _vd),
                KvRow(
                  label: 'Cumul',
                  value: '${_str(result.voltageDrop['cumulative_percent'])} %',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Conducteurs',
            child: Column(
              children: [
                for (final c in result.conductors) ...[
                  KvRow(
                    label: _str(c['role']),
                    value:
                        '#${_str(c['size_awg_kcmil'])} ${_str(c['material'])}  ·  ${_str(c['allowable_amps'])} A',
                  ),
                ],
                if (result.conduits.isNotEmpty)
                  KvRow(
                    label: 'Canalisation',
                    value: _str(result.conduits.first['label'] ?? result.conduits.first['trade_size']),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Card(
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text(
                  'Articles et tableaux cités',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
                children: [
                  for (final r in result.codeReferences)
                    ListTile(
                      dense: true,
                      title: Text(
                        r.table.isEmpty ? r.rule : '${r.rule}  ·  ${r.table}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(r.description),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Code ${ElectroCode.codeVersion}  ·  app ${ElectroCode.appVersion}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: ElectroTheme.muted),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Modifier'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => export.sharePdf(result),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _material(MaterialItem m) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            m.category,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ElectroTheme.muted,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.description,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                '${_qty(m.quantity)} ${m.unit}',
                style: const TextStyle(fontSize: 15, color: ElectroTheme.navy, fontWeight: FontWeight.w700),
              ),
              if (m.notes.isNotEmpty)
                Text(
                  m.notes,
                  style: const TextStyle(fontSize: 13, color: ElectroTheme.muted),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _qty(double q) {
    if (q == q.roundToDouble()) return '${q.round()}';
    return q.toStringAsFixed(1);
  }
}
