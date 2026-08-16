import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:flutter/material.dart';

import '../data/project_store.dart';
import '../services/ocr_service.dart';
import '../services/voice_service.dart';
import 'questions_screen.dart';
import 'result_screen.dart';

class ProjectEditorScreen extends StatefulWidget {
  const ProjectEditorScreen({super.key, required this.project});

  final StoredProject project;

  @override
  State<ProjectEditorScreen> createState() => _ProjectEditorScreenState();
}

class _ProjectEditorScreenState extends State<ProjectEditorScreen> {
  final _store = ProjectStore();
  final _voice = VoiceService();
  final _ocr = OcrService();
  late ProjectInput _input;
  final _desc = TextEditingController();
  final _name = TextEditingController();
  final _area = TextEditingController();
  final _amps = TextEditingController();
  final _heat = TextEditingController();
  final _range = TextEditingController();
  final _dryer = TextEditingController();
  final _wh = TextEditingController();
  final _ev = TextEditingController();
  final _length = TextEditingController();
  final _forced = TextEditingController();

  @override
  void initState() {
    super.initState();
    _input = widget.project.input;
    _name.text = _input.projectName;
    _desc.text = _input.description;
    _area.text = _input.livingAreaM2?.toString() ?? '';
    _amps.text = _input.amperage?.toString() ?? '';
    _heat.text = _input.heatingWatts?.toString() ?? '';
    _range.text = _input.rangeWatts?.toString() ?? '';
    _dryer.text = _input.dryerWatts?.toString() ?? '';
    _wh.text = _input.waterHeaterWatts?.toString() ?? '';
    _ev.text = _input.evChargerAmps?.toString() ?? '';
    _length.text = _input.serviceLengthM?.toString() ?? '';
    _forced.text = _input.forcedServiceConductorSize ?? '';
  }

  @override
  void dispose() {
    _desc.dispose();
    _name.dispose();
    _area.dispose();
    _amps.dispose();
    _heat.dispose();
    _range.dispose();
    _dryer.dispose();
    _wh.dispose();
    _ev.dispose();
    _length.dispose();
    _forced.dispose();
    super.dispose();
  }

  ProjectInput _collect() {
    double? n(TextEditingController c) =>
        c.text.trim().isEmpty ? null : double.tryParse(c.text.replaceAll(',', '.'));
    var info = Map<String, dynamic>.from(_input.additionalInfo);
    if (n(_ev) == null || n(_ev) == 0) {
      info['ev_none'] = true;
    } else {
      info.remove('ev_none');
    }
    return _input.copyWith(
      projectName: _name.text.trim().isEmpty ? 'Projet' : _name.text.trim(),
      description: _desc.text.trim(),
      livingAreaM2: n(_area),
      amperage: n(_amps),
      heatingWatts: n(_heat),
      rangeWatts: n(_range),
      dryerWatts: n(_dryer),
      waterHeaterWatts: n(_wh),
      evChargerAmps: n(_ev),
      serviceLengthM: n(_length),
      forcedServiceConductorSize: _forced.text.trim(),
      additionalInfo: info,
    );
  }

  Future<void> _save(ProjectInput input) async {
    _input = input;
    await _store.save(StoredProject(
      id: widget.project.id,
      input: input,
      lastJson: widget.project.lastJson,
    ));
    setState(() {});
  }

  Future<void> _dictate() async {
    final text = await _voice.listenFrCa();
    if (text == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dictée indisponible (micro / fr_CA).')),
      );
      return;
    }
    final merged = IntakeParser.mergeText(_collect(), text);
    _desc.text = '${_desc.text} $text'.trim();
    if (merged.livingAreaM2 != null) _area.text = '${merged.livingAreaM2}';
    if (merged.amperage != null) _amps.text = '${merged.amperage}';
    await _save(merged);
  }

  Future<void> _attach() async {
    final text = await _ocr.pickAndRecognize();
    if (text == null) return;
    final merged = IntakeParser.mergeText(_collect(), text);
    _desc.text = '${_desc.text}\n$text'.trim();
    await _save(merged);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pièce jointe importée (texte extrait).')),
    );
  }

  Future<void> _run() async {
    final input = _collect();
    await _save(input);
    final result = Dimensioner.run(input, freeText: input.description);
    if (!mounted) return;
    if (result.complianceStatus == ComplianceStatus.questionsEnAttente) {
      final answered = await Navigator.of(context).push<ProjectInput>(
        MaterialPageRoute(
          builder: (_) => QuestionsScreen(input: input, result: result),
        ),
      );
      if (answered == null) return;
      await _save(answered);
      final next = Dimensioner.run(answered);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultScreen(result: next)),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saisie du projet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nom du projet'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<BuildingType>(
            value: _input.buildingType,
            decoration: const InputDecoration(labelText: 'Type de bâtiment'),
            items: BuildingType.values
                .map(
                  (e) => DropdownMenuItem(value: e, child: Text(e.json)),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              _save(_collect().copyWith(buildingType: v));
            },
          ),
          TextField(
            controller: _desc,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Description (texte ou dictée FR-QC)',
            ),
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: _dictate,
                icon: const Icon(Icons.mic),
                label: const Text('Dicter'),
              ),
              TextButton.icon(
                onPressed: _attach,
                icon: const Icon(Icons.attach_file),
                label: const Text('Photo / PDF'),
              ),
            ],
          ),
          const Divider(),
          TextField(
            controller: _area,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Superficie habitable (m²)'),
          ),
          TextField(
            controller: _amps,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Ampérage visé / existant (A)'),
          ),
          DropdownButtonFormField<String>(
            value: _input.voltage,
            decoration: const InputDecoration(labelText: 'Tension'),
            items: const [
              DropdownMenuItem(value: '120/240', child: Text('120/240 V 1ϕ')),
              DropdownMenuItem(value: '120/208', child: Text('120/208 V')),
              DropdownMenuItem(value: '347/600', child: Text('347/600 V')),
            ],
            onChanged: (v) {
              if (v == null) return;
              _save(_collect().copyWith(voltage: v, phases: v.contains('600') ? 3 : 1));
            },
          ),
          DropdownButtonFormField<HeatingType>(
            value: _input.heatingType,
            decoration: const InputDecoration(labelText: 'Chauffage'),
            items: HeatingType.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.json)))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              _save(_collect().copyWith(heatingType: v));
            },
          ),
          TextField(
            controller: _heat,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Chauffage (W)'),
          ),
          TextField(
            controller: _range,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cuisinière (W, 0 si aucune)'),
          ),
          TextField(
            controller: _dryer,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Sécheuse (W, 0 si aucune)'),
          ),
          TextField(
            controller: _wh,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Chauffe-eau (W, 0 si aucun)'),
          ),
          TextField(
            controller: _ev,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Borne VÉ (A, 0 si aucune)'),
          ),
          SwitchListTile(
            title: const Text('Gestion d\'énergie VÉ (EMS)'),
            value: _input.evEnergyManagement ?? false,
            onChanged: (v) => _save(_collect().copyWith(evEnergyManagement: v)),
          ),
          DropdownButtonFormField<ConductorMaterial>(
            value: _input.serviceMaterial,
            decoration: const InputDecoration(labelText: 'Conducteurs de branchement'),
            items: ConductorMaterial.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.labelFr)))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              _save(_collect().copyWith(serviceMaterial: v));
            },
          ),
          TextField(
            controller: _length,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Longueur branchement (m)'),
          ),
          TextField(
            controller: _forced,
            decoration: const InputDecoration(
              labelText: 'Calibre imposé (optionnel, ex. 3 ou 3/0)',
              helperText:
                  'Si trop petit : non conforme, sans surclassement automatique.',
            ),
          ),
          DropdownButtonFormField<GroundingElectrode>(
            value: _input.groundingElectrode == GroundingElectrode.unknown
                ? null
                : _input.groundingElectrode,
            decoration: const InputDecoration(labelText: 'Prise de terre'),
            items: const [
              DropdownMenuItem(value: GroundingElectrode.rods, child: Text('Tiges')),
              DropdownMenuItem(value: GroundingElectrode.plate, child: Text('Plaque')),
              DropdownMenuItem(
                value: GroundingElectrode.concreteEncased,
                child: Text('Électrode enrobée de béton'),
              ),
              DropdownMenuItem(
                value: GroundingElectrode.existingWater,
                child: Text('Liaison canalisation d\'eau existante seulement'),
              ),
              DropdownMenuItem(
                value: GroundingElectrode.municipalWaterNew,
                child: Text('Eau municipale comme NOUVELLE électrode (interdit 2026)'),
              ),
            ],
            onChanged: (v) {
              if (v == null) return;
              _save(_collect().copyWith(groundingElectrode: v));
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _run,
            icon: const Icon(Icons.calculate),
            label: const Text('Dimensionner'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
