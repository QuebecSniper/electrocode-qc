import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/project_store.dart';
import 'labels.dart';
import 'project_editor_screen.dart';
import 'theme.dart';
import 'widgets/field_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _store = ProjectStore();

  @override
  Widget build(BuildContext context) {
    final projects = _store.all();
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ÉlectroCode QC'),
            Text(
              'C22.10:26  ·  hors-ligne',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: projects.isEmpty
          ? _EmptyState(onCreate: _create)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _ProjectCard(
                project: projects[i],
                onOpen: () => _open(projects[i]),
                onDelete: () => _confirmDelete(projects[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau chantier'),
      ),
      bottomNavigationBar: const DisclaimerBar(),
    );
  }

  Future<void> _create() async {
    final created = await _store.create(name: 'Nouveau chantier');
    if (!mounted) return;
    await _open(created);
  }

  Future<void> _open(StoredProject project) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProjectEditorScreen(project: project),
      ),
    );
    setState(() {});
  }

  Future<void> _confirmDelete(StoredProject project) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce chantier ?'),
        content: Text(project.input.projectName),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _store.delete(project.id);
    setState(() {});
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.electrical_services, size: 56, color: ElectroTheme.navy),
            const SizedBox(height: 16),
            Text(
              'Aucun chantier',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Créez un dimensionnement résidentiel.\nSaisie, questions s’il manque une donnée, puis le résultat.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: ElectroTheme.muted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Nouveau chantier'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.onOpen,
    required this.onDelete,
  });

  final StoredProject project;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  String? get _statusJson {
    final raw = project.lastJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map['compliance_status'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final input = project.input;
    final status = _statusJson;
    final bits = <String>[
      FieldLabels.building(input.buildingType),
      if (input.livingAreaM2 != null) '${input.livingAreaM2!.round()} m²',
      if (input.amperage != null) '${input.amperage!.round()} A',
    ];
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: ElectroTheme.navy,
                foregroundColor: Colors.white,
                child: Icon(Icons.home_work_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      input.projectName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bits.join('  ·  '),
                      style: const TextStyle(fontSize: 14, color: ElectroTheme.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FieldLabels.formatWhen(project.updatedAt),
                      style: const TextStyle(fontSize: 13, color: ElectroTheme.muted),
                    ),
                  ],
                ),
              ),
              _StatusChip(statusJson: status),
              IconButton(
                tooltip: 'Supprimer',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.statusJson});

  final String? statusJson;

  @override
  Widget build(BuildContext context) {
    final label = FieldLabels.statusFromJson(statusJson);
    Color fg;
    Color bg;
    switch (statusJson) {
      case 'conforme':
        fg = ElectroTheme.ok;
        bg = const Color(0xFFE6F6EC);
      case 'non_conforme':
        fg = ElectroTheme.bad;
        bg = const Color(0xFFFEECEC);
      case 'questions_en_attente':
        fg = ElectroTheme.wait;
        bg = const Color(0xFFFFF4E5);
      default:
        fg = ElectroTheme.muted;
        bg = const Color(0xFFF2F4F7);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}
