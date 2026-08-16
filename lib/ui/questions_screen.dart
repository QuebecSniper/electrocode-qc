import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:flutter/material.dart';

import 'theme.dart';
import 'widgets/field_ui.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({
    super.key,
    required this.input,
    required this.result,
  });

  final ProjectInput input;
  final CalculationResult result;

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final q in widget.result.questionsAsked)
        q.id: TextEditingController(text: q.answer ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _set(String id, String value) {
    _controllers[id]?.text = value;
    setState(() {});
  }

  ProjectInput _apply(ProjectInput base) {
    var out = base;
    final answers = Map<String, String?>.from(base.answers);
    for (final q in widget.result.questionsAsked) {
      final raw = _controllers[q.id]?.text.trim() ?? '';
      answers[q.id] = raw.isEmpty ? null : raw;
      final n = double.tryParse(raw.replaceAll(',', '.'));
      switch (q.id) {
        case 'living_area_m2':
          if (n != null) out = out.copyWith(livingAreaM2: n);
        case 'heating_watts':
          if (n != null) out = out.copyWith(heatingWatts: n);
        case 'range_watts':
          if (n != null) out = out.copyWith(rangeWatts: n);
        case 'dryer_watts':
          if (n != null) out = out.copyWith(dryerWatts: n);
        case 'water_heater_watts':
          if (n != null) out = out.copyWith(waterHeaterWatts: n);
        case 'service_length_m':
          if (n != null) out = out.copyWith(serviceLengthM: n);
        case 'ev_managed_watts':
          if (n != null) out = out.copyWith(evManagedWatts: n);
        case 'heating_type':
          out = out.copyWith(heatingType: HeatingType.fromJson(raw));
        case 'service_material':
          if (raw.isNotEmpty) {
            out = out.copyWith(serviceMaterial: ConductorMaterial.fromJson(raw));
          }
        case 'grounding_electrode':
          if (raw.isNotEmpty) {
            out = out.copyWith(
              groundingElectrode: GroundingElectrode.fromJson(raw),
            );
          }
        case 'building_type_v1':
          if (raw == 'residential') {
            out = out.copyWith(buildingType: BuildingType.residential);
          }
        case 'ev_charger':
          if (raw == '0' || raw.toLowerCase().contains('non')) {
            out = out.copyWith(
              evChargerWatts: 0,
              additionalInfo: {...out.additionalInfo, 'ev_none': true},
            );
          } else if (n != null) {
            if (n <= 100) {
              out = out.copyWith(evChargerAmps: n);
            } else {
              out = out.copyWith(evChargerWatts: n);
            }
          }
        case 'ev_ems':
          final yes = raw.toLowerCase().startsWith('o') ||
              raw.toLowerCase() == 'oui' ||
              raw.toLowerCase() == 'true';
          out = out.copyWith(evEnergyManagement: yes);
        default:
          break;
      }
    }
    return out.copyWith(answers: answers);
  }

  bool get _allAnswered {
    for (final q in widget.result.questionsAsked) {
      if (q.id == 'building_type_v1') {
        if ((_controllers[q.id]?.text ?? '') != 'residential') return false;
        continue;
      }
      if ((_controllers[q.id]?.text.trim() ?? '').isEmpty) return false;
    }
    return widget.result.questionsAsked.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Données manquantes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const StepHeader(current: 2, total: 3),
          Text(
            '${widget.result.questionsAsked.length} question(s) pour terminer le calcul C22.10:26.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          ...widget.result.questionsAsked.map(_questionCard),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: FilledButton.icon(
            onPressed: _allAnswered
                ? () => Navigator.of(context).pop(_apply(widget.input))
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continuer'),
          ),
        ),
      ),
    );
  }

  Widget _questionCard(QuestionAsked q) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        title: _shortTitle(q.id),
        subtitle: q.question,
        child: _control(q),
      ),
    );
  }

  String _shortTitle(String id) {
    switch (id) {
      case 'living_area_m2':
        return 'Superficie';
      case 'heating_type':
        return 'Chauffage';
      case 'heating_watts':
        return 'Charge chauffage';
      case 'range_watts':
        return 'Cuisinière';
      case 'dryer_watts':
        return 'Sécheuse';
      case 'water_heater_watts':
        return 'Chauffe-eau';
      case 'ev_charger':
        return 'Borne VÉ';
      case 'ev_ems':
        return 'EMS / délestage';
      case 'ev_managed_watts':
        return 'Charge VÉ gérée';
      case 'service_material':
        return 'Conducteurs';
      case 'service_length_m':
        return 'Longueur';
      case 'grounding_electrode':
        return 'Prise de terre';
      case 'building_type_v1':
        return 'Type de bâtiment';
      default:
        return 'Donnée requise';
    }
  }

  Widget _control(QuestionAsked q) {
    final current = _controllers[q.id]?.text ?? '';
    switch (q.id) {
      case 'building_type_v1':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'La V1 calcule uniquement le résidentiel.',
              style: TextStyle(fontSize: 16, color: ElectroTheme.bad),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                _set(q.id, 'residential');
                Navigator.of(context).pop(_apply(widget.input));
              },
              child: const Text('Passer en résidentiel'),
            ),
          ],
        );
      case 'heating_type':
        return _chips(q.id, {
          'electric': 'Électrique',
          'heat_pump': 'Thermopompe',
          'fossil': 'Fossile',
          'none': 'Aucun',
        });
      case 'service_material':
        return _chips(q.id, {
          'Cu': 'Cuivre',
          'Al': 'Aluminium',
        });
      case 'grounding_electrode':
        return _chips(q.id, {
          'rods': 'Tiges',
          'plate': 'Plaque',
          'concrete_encased': 'Béton',
          'existing_water': 'Liaison eau existante',
        });
      case 'ev_ems':
        return _chips(q.id, {'oui': 'Oui', 'non': 'Non'});
      case 'range_watts':
      case 'dryer_watts':
      case 'water_heater_watts':
      case 'ev_charger':
        return Column(
          children: [
            TextField(
              controller: _controllers[q.id],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Valeur'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () => _set(q.id, '0'),
                child: const Text('Aucune / 0'),
              ),
            ),
          ],
        );
      default:
        final numeric = q.id.contains('watts') ||
            q.id.contains('m2') ||
            q.id.contains('length') ||
            q.id.contains('amps');
        return TextField(
          controller: _controllers[q.id],
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(
            labelText: numeric ? 'Valeur' : 'Réponse',
            helperText: current.isEmpty ? 'Obligatoire' : null,
          ),
          onChanged: (_) => setState(() {}),
        );
    }
  }

  Widget _chips(String id, Map<String, String> options) {
    final selected = _controllers[id]?.text ?? '';
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in options.entries)
          ChoiceChip(
            label: Text(e.value, style: const TextStyle(fontSize: 15)),
            selected: selected == e.key,
            selectedColor: ElectroTheme.navy,
            labelStyle: TextStyle(
              color: selected == e.key ? Colors.white : ElectroTheme.ink,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => _set(id, e.key),
          ),
      ],
    );
  }
}
