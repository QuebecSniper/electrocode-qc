import '../models/calculation_result.dart';
import '../models/enums.dart';
import '../tables/code_tables.dart';
import 'demand.dart';

class ServiceResult {
  final double calculatedAmps;
  final int minimumByArea;
  final int selectedAmps;
  final String conductorSize;
  final String material;
  final List<CodeReference> references;
  final List<String> warnings;

  const ServiceResult({
    required this.calculatedAmps,
    required this.minimumByArea,
    required this.selectedAmps,
    required this.conductorSize,
    required this.material,
    required this.references,
    required this.warnings,
  });

  Map<String, dynamic> toJson() => {
        'calculated_amps': double.parse(calculatedAmps.toStringAsFixed(1)),
        'minimum_amps_8_200': minimumByArea,
        'selected_amps': selectedAmps,
        'ungrounded_conductor': conductorSize,
        'identified_conductor': conductorSize,
        'material': material,
        'voltage': '120/240',
        'phases': 1,
      };
}

class ServiceCalculator {
  /// 8-200(2) : 60 A si superficie ≤ 80 m², sinon 100 A minimum.
  static int minimumServiceAmps(double areaM2) {
    if (areaM2 <= 80) return 60;
    return 100;
  }

  static ServiceResult calculate({
    required DemandBreakdown demand,
    required ConductorMaterial material,
    double? requestedAmps,
  }) {
    final minA = minimumServiceAmps(demand.livingAreaM2);
    var target = demand.calculatedAmps;
    if (target < minA) target = minA.toDouble();
    if (requestedAmps != null && requestedAmps > target) {
      target = requestedAmps;
    }
    final selected = BreakerTables.nextPanel(target);
    final pick = AmpacityTables.smallestFor(
      requiredAmps: selected.toDouble(),
      material: material,
    );
    final warnings = <String>[];
    if (pick == null) {
      warnings.add(
        'Aucun calibre de table de travail ne couvre $selected A en ${material.labelFr}. Vérifier T2/T4 officiels.',
      );
    }
    return ServiceResult(
      calculatedAmps: demand.calculatedAmps,
      minimumByArea: minA,
      selectedAmps: selected,
      conductorSize: pick?.size ?? 'N/D',
      material: material.json,
      references: [
        const CodeReference(
          rule: '8-200',
          table: '',
          description:
              'Ampacité minimale du branchement : 60 A si superficie ≤ 80 m², 100 A au-delà.',
        ),
        CodeReference(
          rule: '4-004 / 4-006',
          table: AmpacityTables.ampacityTable(material),
          description:
              'Ampacité des conducteurs de branchement — colonne 75 °C (terminaisons).',
        ),
        const CodeReference(
          rule: '4-004',
          table: 'T5A',
          description: 'Facteurs de correction pour température ambiante.',
        ),
        const CodeReference(
          rule: '4-004',
          table: 'T5C',
          description: 'Facteurs de correction pour plus de 3 conducteurs sous tension.',
        ),
        const CodeReference(
          rule: '6',
          table: '',
          description:
              'Branchement : coffret hors niveau de crue ; coffret extérieur permis (QC 2026).',
        ),
      ],
      warnings: warnings,
    );
  }
}
