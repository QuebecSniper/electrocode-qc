import '../constants.dart';
import '../models/calculation_result.dart';

class SchemaValidationException implements Exception {
  final List<String> errors;
  SchemaValidationException(this.errors);

  @override
  String toString() => errors.join('\n');
}

/// Valide le JSON standard obligatoire (miroir de schemas/electrocode-result.schema.json).
class ResultSchemaValidator {
  static const requiredRoot = [
    'meta',
    'input',
    'questions_asked',
    'calculations',
    'materials_list',
    'code_references',
    'warnings',
    'compliance_status',
    'disclaimer',
  ];

  static const requiredMeta = [
    'app_version',
    'code_version',
    'calculation_date',
    'project_name',
    'building_type',
  ];

  static const requiredInput = [
    'description',
    'voltage',
    'amperage',
    'phases',
    'loads',
    'additional_info',
  ];

  static const requiredCalc = [
    'service',
    'main_panel',
    'sub_panels',
    'transformers',
    'breakers',
    'conductors',
    'conduits',
    'grounding',
    'voltage_drop',
  ];

  static const buildingTypes = [
    'residential',
    'commercial',
    'institutional',
    'industrial',
  ];

  static const statuses = [
    'conforme',
    'non_conforme',
    'questions_en_attente',
  ];

  static List<String> validate(Map<String, dynamic> json) {
    final errors = <String>[];
    for (final k in requiredRoot) {
      if (!json.containsKey(k)) errors.add('Champ racine manquant : $k');
    }
    final meta = json['meta'];
    if (meta is Map) {
      for (final k in requiredMeta) {
        if (!meta.containsKey(k)) errors.add('meta.$k manquant');
      }
      if (meta['building_type'] is String &&
          !buildingTypes.contains(meta['building_type'])) {
        errors.add('meta.building_type invalide');
      }
    } else if (json.containsKey('meta')) {
      errors.add('meta doit être un objet');
    }

    final input = json['input'];
    if (input is Map) {
      for (final k in requiredInput) {
        if (!input.containsKey(k)) errors.add('input.$k manquant');
      }
      if (input['phases'] != null &&
          input['phases'] != 1 &&
          input['phases'] != 3) {
        errors.add('input.phases doit être 1 ou 3');
      }
    }

    final calc = json['calculations'];
    if (calc is Map) {
      for (final k in requiredCalc) {
        if (!calc.containsKey(k)) errors.add('calculations.$k manquant');
      }
    }

    if (json['questions_asked'] is! List) {
      errors.add('questions_asked doit être un tableau');
    } else {
      for (final q in json['questions_asked'] as List) {
        if (q is! Map || !q.containsKey('question') || !q.containsKey('answer')) {
          errors.add('question invalide (question/answer requis)');
          break;
        }
      }
    }

    if (json['materials_list'] is List) {
      for (final m in json['materials_list'] as List) {
        if (m is! Map) continue;
        for (final k in ['category', 'description', 'quantity', 'unit', 'notes']) {
          if (!m.containsKey(k)) {
            errors.add('materials_list item sans $k');
            break;
          }
        }
      }
    }

    if (json['code_references'] is List) {
      for (final r in json['code_references'] as List) {
        if (r is! Map) continue;
        for (final k in ['rule', 'table', 'description']) {
          if (!r.containsKey(k)) {
            errors.add('code_references item sans $k');
            break;
          }
        }
      }
    }

    if (json['warnings'] is! List) {
      errors.add('warnings doit être un tableau');
    }
    if (json['compliance_status'] is String &&
        !statuses.contains(json['compliance_status'])) {
      errors.add('compliance_status invalide');
    }
    if (json['disclaimer'] != ElectroCode.disclaimer) {
      errors.add('disclaimer obligatoire non conforme');
    }
    return errors;
  }

  static void assertValid(CalculationResult result) {
    final errors = validate(result.toJson());
    if (errors.isNotEmpty) {
      throw SchemaValidationException(errors);
    }
  }
}
