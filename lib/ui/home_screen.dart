import 'package:flutter/material.dart';

import '../data/project_store.dart';
import 'project_editor_screen.dart';
import 'theme.dart';

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
            Text('C22.10:26 — hors-ligne', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: ElectroTheme.amber.withValues(alpha: 0.25),
            padding: const EdgeInsets.all(12),
            child: const Text(
              "Outil d'aide. La responsabilité finale appartient à l'électricien titulaire de la licence.",
              style: TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: projects.isEmpty
                ? const Center(
                    child: Text('Aucun projet local. Créez un dimensionnement.'),
                  )
                : ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (ctx, i) {
                      final p = projects[i];
                      return ListTile(
                        leading: const Icon(Icons.electrical_services),
                        title: Text(p.input.projectName),
                        subtitle: Text(
                          '${p.input.buildingType.json} · ${p.updatedAt.toLocal()}',
                        ),
                        onTap: () => _open(p),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await _store.delete(p.id);
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await _store.create(name: 'Nouveau projet');
          if (!context.mounted) return;
          await _open(created);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau'),
      ),
    );
  }

  Future<void> _open(StoredProject project) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProjectEditorScreen(project: project),
      ),
    );
    setState(() {});
  }
}
