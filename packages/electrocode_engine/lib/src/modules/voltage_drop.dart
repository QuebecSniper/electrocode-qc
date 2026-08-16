import '../models/enums.dart';
import '../tables/code_tables.dart';
import 'conductors.dart';

class VoltageDropResult {
  final double lengthM;
  final double currentA;
  final int voltage;
  final int phases;
  final String size;
  final String material;
  final double dropVolts;
  final double dropPercent;
  final double limitPercent;
  final bool compliant;
  final String role;

  const VoltageDropResult({
    required this.lengthM,
    required this.currentA,
    required this.voltage,
    required this.phases,
    required this.size,
    required this.material,
    required this.dropVolts,
    required this.dropPercent,
    required this.limitPercent,
    required this.compliant,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'length_m': lengthM,
        'current_a': double.parse(currentA.toStringAsFixed(1)),
        'voltage': voltage,
        'phases': phases,
        'conductor': size,
        'material': material,
        'drop_volts': double.parse(dropVolts.toStringAsFixed(2)),
        'drop_percent': double.parse(dropPercent.toStringAsFixed(2)),
        'limit_percent': limitPercent,
        'conforme_8_102': compliant,
      };
}

class VoltageDropCalculator {
  /// 8-102 : 3 % par feeder ou dérivation ; 5 % total.
  static VoltageDropResult calculate({
    required ConductorPick conductor,
    required double lengthM,
    required int phases,
    double limitPercent = 3.0,
    String role = 'feeder',
  }) {
    final row = AmpacityTablesLookup.ohms(conductor.size, conductor.material);
    final r = row;
    final i = conductor.circuitAmps.toDouble();
    final v = conductor.voltage.toDouble();
    final factor = phases == 3 ? 1.732 : 2.0;
    final dropV = r <= 0 || lengthM <= 0
        ? 0.0
        : factor * i * (lengthM / 1000.0) * r;
    final pct = v == 0 ? 0.0 : dropV / v * 100.0;
    return VoltageDropResult(
      lengthM: lengthM,
      currentA: i,
      voltage: conductor.voltage,
      phases: phases,
      size: conductor.size,
      material: conductor.material.json,
      dropVolts: dropV,
      dropPercent: pct,
      limitPercent: limitPercent,
      compliant: pct <= limitPercent + 1e-9,
      role: role,
    );
  }

  static ConductorPick upsizeForDrop({
    required ConductorPick initial,
    required double lengthM,
    required int phases,
    double limitPercent = 3.0,
  }) {
    var current = initial;
    var vd = calculate(
      conductor: current,
      lengthM: lengthM,
      phases: phases,
      limitPercent: limitPercent,
      role: initial.role,
    );
    final sizes = AmpacityTablesLookup.sizes;
    var idx = sizes.indexOf(current.size);
    while (!vd.compliant && idx >= 0 && idx < sizes.length - 1) {
      idx++;
      final next = ConductorPick(
        size: sizes[idx],
        material: current.material,
        requiredAmps: current.requiredAmps,
        allowableAmps: AmpacityTablesLookup.allowable(
          sizes[idx],
          current.material,
        ),
        insulationTempC: current.insulationTempC,
        ambientFactor: current.ambientFactor,
        groupingFactor: current.groupingFactor,
        role: current.role,
        voltage: current.voltage,
        circuitAmps: current.circuitAmps,
      );
      current = next;
      vd = calculate(
        conductor: current,
        lengthM: lengthM,
        phases: phases,
        limitPercent: limitPercent,
        role: current.role,
      );
    }
    return current;
  }
}

class AmpacityTablesLookup {
  static List<String> get sizes =>
      AmpacityTables.wires.map((e) => e.size).toList();

  static double ohms(String size, ConductorMaterial material) {
    final row = AmpacityTables.bySize(size);
    if (row == null) return 0;
    return row.ohmsPerKm(material);
  }

  static double allowable(String size, ConductorMaterial material) {
    final row = AmpacityTables.bySize(size);
    if (row == null) return 0;
    return row.ampacity(material);
  }
}
