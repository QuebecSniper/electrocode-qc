import '../models/enums.dart';
import '../tables/code_tables.dart';

class ConductorPick {
  final String size;
  final ConductorMaterial material;
  final double requiredAmps;
  final double allowableAmps;
  final int insulationTempC;
  final double ambientFactor;
  final double groupingFactor;
  final String role;
  final int voltage;
  final int circuitAmps;

  const ConductorPick({
    required this.size,
    required this.material,
    required this.requiredAmps,
    required this.allowableAmps,
    required this.insulationTempC,
    required this.ambientFactor,
    required this.groupingFactor,
    required this.role,
    required this.voltage,
    required this.circuitAmps,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'size_awg_kcmil': size,
        'material': material.json,
        'required_amps': double.parse(requiredAmps.toStringAsFixed(1)),
        'allowable_amps': double.parse(allowableAmps.toStringAsFixed(1)),
        'insulation_temp_c': insulationTempC,
        'ambient_factor_table_5A': ambientFactor,
        'grouping_factor_table_5C': groupingFactor,
        'voltage': voltage,
        'circuit_amps': circuitAmps,
      };
}

class ConductorSizer {
  static ConductorPick? sizeFor({
    required double loadAmps,
    required bool continuous,
    required ConductorMaterial material,
    required String role,
    required int voltage,
    int ambientC = 30,
    int currentCarrying = 3,
    int insulationTempC = 75,
  }) {
    final required = continuous ? loadAmps * 1.25 : loadAmps;
    final amb = AmpacityTables.ambientFactor(ambientC);
    final grp = AmpacityTables.groupingFactor(currentCarrying);
    final row = AmpacityTables.smallestFor(
      requiredAmps: required,
      material: material,
      tempC: insulationTempC,
      ambientCorr: amb,
      groupingCorr: grp,
    );
    if (row == null) return null;
    var allowed = row.ampacity(material, tempC: insulationTempC) * amb * grp;
    final limit = AmpacityTables.smallWireLimit(row.size, material);
    if (limit.isFinite && allowed > limit) allowed = limit;
    return ConductorPick(
      size: row.size,
      material: material,
      requiredAmps: required,
      allowableAmps: allowed,
      insulationTempC: insulationTempC,
      ambientFactor: amb,
      groupingFactor: grp,
      role: role,
      voltage: voltage,
      circuitAmps: loadAmps.round(),
    );
  }

  /// Évalue un calibre imposé sans le surclasser.
  static ConductorPick? evaluateImposed({
    required String size,
    required double loadAmps,
    required bool continuous,
    required ConductorMaterial material,
    required String role,
    required int voltage,
    int ambientC = 30,
    int currentCarrying = 3,
    int insulationTempC = 75,
  }) {
    final normalized = AmpacityTables.normalizeSize(size);
    if (normalized == null) return null;
    final row = AmpacityTables.bySize(normalized);
    if (row == null) return null;
    final required = continuous ? loadAmps * 1.25 : loadAmps;
    final amb = AmpacityTables.ambientFactor(ambientC);
    final grp = AmpacityTables.groupingFactor(currentCarrying);
    var allowed = row.ampacity(material, tempC: insulationTempC) * amb * grp;
    final limit = AmpacityTables.smallWireLimit(row.size, material);
    if (limit.isFinite && allowed > limit) allowed = limit;
    return ConductorPick(
      size: row.size,
      material: material,
      requiredAmps: required,
      allowableAmps: allowed,
      insulationTempC: insulationTempC,
      ambientFactor: amb,
      groupingFactor: grp,
      role: role,
      voltage: voltage,
      circuitAmps: loadAmps.round(),
    );
  }

  static bool ampacitySufficient(ConductorPick pick) {
    return pick.allowableAmps + 1e-9 >= pick.requiredAmps;
  }
}

class BreakerSizer {
  static int forCircuit({
    required double loadAmps,
    required bool continuous,
    required String conductorSize,
    required double conductorAllowable,
  }) {
    final design = continuous ? loadAmps * 1.25 : loadAmps;
    var ocpd = BreakerTables.nextStandard(design);
    if (ocpd > conductorAllowable + 1e-9) {
      if (BreakerTables.nextSizeUpAllowed(conductorSize) &&
          ocpd == BreakerTables.nextStandard(conductorAllowable + 0.01)) {
        return ocpd;
      }
      ocpd = BreakerTables.nextStandard(conductorAllowable);
      while (ocpd > conductorAllowable + 1e-9) {
        final idx = BreakerTables.standard.indexOf(ocpd);
        if (idx <= 0) break;
        ocpd = BreakerTables.standard[idx - 1];
      }
    }
    return ocpd;
  }
}
