import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Questions manquantes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Le moteur pose uniquement ce qui manque pour un calcul C22.10:26.',
          ),
          const SizedBox(height: 12),
          ...widget.result.questionsAsked.map(
            (q) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _controllers[q.id],
                decoration: InputDecoration(
                  labelText: q.id,
                  helperText: q.question,
                ),
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_apply(widget.input)),
            child: const Text('Continuer le calcul'),
          ),
        ],
      ),
    );
  }
}
