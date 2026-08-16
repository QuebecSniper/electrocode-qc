import 'dart:convert';

import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:flutter/material.dart';

import '../data/project_store.dart';
import '../services/ocr_service.dart';
import '../services/voice_service.dart';
import 'labels.dart';
import 'questions_screen.dart';
import 'result_screen.dart';
import 'theme.dart';
import 'widgets/field_ui.dart';

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
  String? _lastJson;
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
    _lastJson = widget.project.lastJson;
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
      projectName: _name.text.trim().isEmpty ? 'Chantier' : _name.text.trim(),
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

  Future<void> _save(ProjectInput input, {String? lastJson}) async {
    _input = input;
    if (lastJson != null) _lastJson = lastJson;
    await _store.save(StoredProject(
      id: widget.project.id,
      input: input,
      lastJson: _lastJson,
    ));
    if (mounted) setState(() {});
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16)),
        backgroundColor: error ? ElectroTheme.bad : ElectroTheme.navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _dictate() async {
    _snack('Écoute… parlez maintenant (français Québec).');
    final heard = await _voice.listenFrCa();
    if (!mounted) return;
    if (!heard.ok || heard.text == null) {
      _snack(heard.message, error: true);
      return;
    }
    final merged = IntakeParser.mergeText(_collect(), heard.text!);
    _desc.text = '${_desc.text} ${heard.text}'.trim();
    if (merged.livingAreaM2 != null) _area.text = '${merged.livingAreaM2}';
    if (merged.amperage != null) _amps.text = '${merged.amperage}';
    if (merged.heatingWatts != null) _heat.text = '${merged.heatingWatts}';
    await _save(merged);
    if (!mounted) return;
    _snack(heard.message);
  }

  Future<void> _attach() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Prendre une photo'),
              subtitle: const Text('Plan, cartouche, liste de charges'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Choisir une image'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Choisir un PDF'),
              subtitle: const Text('Calque texte uniquement'),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
            ListTile(
              title: const Text('Annuler'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text('Lecture du document…')),
          ],
        ),
      ),
    );

    ExtractResult extract;
    try {
      switch (choice) {
        case 'camera':
          extract = await _ocr.capturePhoto();
        case 'gallery':
          extract = await _ocr.pickGalleryImage();
        default:
          extract = await _ocr.pickAndRecognize();
      }
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
    if (!mounted) return;
    if (extract.status == ExtractStatus.cancelled) return;
    if (!extract.hasText) {
      _snack(extract.userMessage, error: true);
      return;
    }
    final merged = IntakeParser.mergeText(_collect(), extract.text);
    _desc.text = '${_desc.text}\n${extract.text}'.trim();
    if (merged.livingAreaM2 != null) _area.text = '${merged.livingAreaM2}';
    if (merged.amperage != null) _amps.text = '${merged.amperage}';
    if (merged.heatingWatts != null) _heat.text = '${merged.heatingWatts}';
    await _save(merged);
    if (!mounted) return;
    _snack(extract.userMessage);
  }

  Future<void> _run() async {
    var input = _collect();
    await _save(input);
    if (!mounted) return;

    var result = Dimensioner.run(input, freeText: input.description);
    while (result.complianceStatus == ComplianceStatus.questionsEnAttente) {
      final answered = await Navigator.of(context).push<ProjectInput>(
        MaterialPageRoute(
          builder: (_) => QuestionsScreen(input: input, result: result),
        ),
      );
      if (answered == null) return;
      input = answered;
      await _save(input);
      result = Dimensioner.run(input);
      if (!mounted) return;
    }

    await _save(input, lastJson: jsonEncode(result.toJson()));
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  void _zero(TextEditingController c) {
    c.text = '0';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saisie du chantier')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const StepHeader(current: 1, total: 3),
          SectionCard(
            title: 'Chantier',
            subtitle: 'Nommez le logement. La V1 calcule le résidentiel seulement.',
            child: Column(
              children: [
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nom du chantier',
                    hintText: 'Ex. Bungalow Laval, panneau 200 A',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<BuildingType>(
                  key: ValueKey(_input.buildingType),
                  initialValue: _input.buildingType,
                  decoration: const InputDecoration(labelText: 'Type de bâtiment'),
                  items: BuildingType.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(FieldLabels.building(e)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    _save(_collect().copyWith(buildingType: v));
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _desc,
                  minLines: 2,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Notes / dictée',
                    hintText: 'Ex. 120 m², chauffage 15 kW, tiges, 25 m',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _dictate,
                        icon: const Icon(Icons.mic),
                        label: const Text('Dicter'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _attach,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Photo / PDF'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Logement',
            child: Column(
              children: [
                TextField(
                  controller: _area,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Superficie habitable (m²)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amps,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ampérage visé / existant (A)',
                    helperText: 'Laisser vide pour que le moteur propose le service.',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey(_input.voltage),
                  initialValue: _input.voltage,
                  decoration: const InputDecoration(labelText: 'Tension'),
                  items: const [
                    DropdownMenuItem(value: '120/240', child: Text('120/240 V  (1 phase)')),
                    DropdownMenuItem(value: '120/208', child: Text('120/208 V')),
                    DropdownMenuItem(value: '347/600', child: Text('347/600 V')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    _save(_collect().copyWith(voltage: v, phases: v.contains('600') ? 3 : 1));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Charges',
            subtitle: 'Mettez 0 s’il n’y a pas l’appareil — sinon le moteur repose la question.',
            child: Column(
              children: [
                DropdownButtonFormField<HeatingType>(
                  key: ValueKey(_input.heatingType),
                  initialValue: _input.heatingType,
                  hint: const Text('Choisir'),
                  decoration: const InputDecoration(labelText: 'Chauffage'),
                  items: HeatingType.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(FieldLabels.heating(e)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    _save(_collect().copyWith(heatingType: v));
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _heat,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Chauffage électrique (W)'),
                ),
                const SizedBox(height: 12),
                _optionalWatts(_range, 'Cuisinière électrique (W)'),
                const SizedBox(height: 12),
                _optionalWatts(_dryer, 'Sécheuse électrique (W)'),
                const SizedBox(height: 12),
                _optionalWatts(_wh, 'Chauffe-eau électrique (W)'),
                const SizedBox(height: 12),
                _optionalWatts(_ev, 'Borne VÉ (A)', noneLabel: 'Aucune'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Gestion d’énergie VÉ (EMS)'),
                  subtitle: const Text('Délestage / charge gérée'),
                  value: _input.evEnergyManagement ?? false,
                  onChanged: (v) => _save(_collect().copyWith(evEnergyManagement: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Branchement et terre',
            child: Column(
              children: [
                DropdownButtonFormField<ConductorMaterial>(
                  key: ValueKey(_input.serviceMaterial),
                  initialValue: _input.serviceMaterial,
                  hint: const Text('Cuivre ou aluminium'),
                  decoration: const InputDecoration(
                    labelText: 'Conducteurs de branchement',
                  ),
                  items: ConductorMaterial.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.labelFr)),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    _save(_collect().copyWith(serviceMaterial: v));
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _length,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Longueur du branchement (m)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _forced,
                  decoration: const InputDecoration(
                    labelText: 'Calibre imposé (optionnel)',
                    hintText: 'Ex. 3  ou  3/0',
                    helperText:
                        'Vérifie un calibre existant. Trop petit = non conforme, sans surclassement.',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<GroundingElectrode>(
                  key: ValueKey(_input.groundingElectrode),
                  initialValue: _input.groundingElectrode == GroundingElectrode.unknown
                      ? null
                      : _input.groundingElectrode,
                  hint: const Text('Choisir'),
                  decoration: const InputDecoration(labelText: 'Prise de terre'),
                  items: const [
                    DropdownMenuItem(
                      value: GroundingElectrode.rods,
                      child: Text('Tiges'),
                    ),
                    DropdownMenuItem(
                      value: GroundingElectrode.plate,
                      child: Text('Plaque'),
                    ),
                    DropdownMenuItem(
                      value: GroundingElectrode.concreteEncased,
                      child: Text('Électrode enrobée de béton'),
                    ),
                    DropdownMenuItem(
                      value: GroundingElectrode.existingWater,
                      child: Text('Liaison eau existante seulement'),
                    ),
                    DropdownMenuItem(
                      value: GroundingElectrode.municipalWaterNew,
                      child: Text('Eau municipale (interdit 2026)'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    _save(_collect().copyWith(groundingElectrode: v));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: FilledButton.icon(
            onPressed: _run,
            icon: const Icon(Icons.calculate),
            label: const Text('Dimensionner'),
          ),
        ),
      ),
    );
  }

  Widget _optionalWatts(
    TextEditingController c,
    String label, {
    String noneLabel = 'Aucune',
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: c,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: label),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: OutlinedButton(
            onPressed: () => _zero(c),
            child: Text(noneLabel),
          ),
        ),
      ],
    );
  }
}
