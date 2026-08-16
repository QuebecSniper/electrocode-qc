import '../constants.dart';
import 'enums.dart';

class CodeReference {
  final String rule;
  final String table;
  final String description;

  const CodeReference({
    required this.rule,
    this.table = '',
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'rule': rule,
        'table': table,
        'description': description,
      };
}

class MaterialItem {
  final String category;
  final String description;
  final double quantity;
  final String unit;
  final String notes;

  const MaterialItem({
    required this.category,
    required this.description,
    required this.quantity,
    required this.unit,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'description': description,
        'quantity': quantity,
        'unit': unit,
        'notes': notes,
      };
}

class QuestionAsked {
  final String id;
  final String question;
  final String? answer;

  const QuestionAsked({
    required this.id,
    required this.question,
    this.answer,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };
}

class CalculationResult {
  final String projectName;
  final BuildingType buildingType;
  final Map<String, dynamic> input;
  final List<QuestionAsked> questionsAsked;
  final Map<String, dynamic> service;
  final Map<String, dynamic> mainPanel;
  final List<Map<String, dynamic>> subPanels;
  final List<Map<String, dynamic>> transformers;
  final List<Map<String, dynamic>> breakers;
  final List<Map<String, dynamic>> conductors;
  final List<Map<String, dynamic>> conduits;
  final Map<String, dynamic> grounding;
  final Map<String, dynamic> voltageDrop;
  final List<MaterialItem> materials;
  final List<CodeReference> codeReferences;
  final List<String> warnings;
  final ComplianceStatus complianceStatus;
  final DateTime calculationDate;

  CalculationResult({
    required this.projectName,
    required this.buildingType,
    required this.input,
    required this.questionsAsked,
    required this.service,
    required this.mainPanel,
    required this.subPanels,
    this.transformers = const [],
    required this.breakers,
    required this.conductors,
    required this.conduits,
    required this.grounding,
    required this.voltageDrop,
    required this.materials,
    required this.codeReferences,
    required this.warnings,
    required this.complianceStatus,
    DateTime? calculationDate,
  }) : calculationDate = calculationDate ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() => {
        'meta': {
          'app_version': ElectroCode.appVersion,
          'code_version': ElectroCode.codeVersion,
          'calculation_date': calculationDate.toIso8601String(),
          'project_name': projectName,
          'building_type': buildingType.json,
        },
        'input': input,
        'questions_asked': questionsAsked.map((e) => e.toJson()).toList(),
        'calculations': {
          'service': service,
          'main_panel': mainPanel,
          'sub_panels': subPanels,
          'transformers': transformers,
          'breakers': breakers,
          'conductors': conductors,
          'conduits': conduits,
          'grounding': grounding,
          'voltage_drop': voltageDrop,
        },
        'materials_list': materials.map((e) => e.toJson()).toList(),
        'code_references': codeReferences.map((e) => e.toJson()).toList(),
        'warnings': warnings,
        'compliance_status': complianceStatus.json,
        'disclaimer': ElectroCode.disclaimer,
      };
}
