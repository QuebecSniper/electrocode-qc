import '../models/calculation_result.dart';
import '../models/enums.dart';
import '../models/load_input.dart';
import '../models/project_input.dart';

class DemandBreakdown {
  final double livingAreaM2;
  final int dwellingUnits;
  final String method;
  final double basicWatts;
  final double heatingDemandWatts;
  final double acWatts;
  final double climateWatts;
  final double rangeDemandWatts;
  final double dryerWatts;
  final double waterHeaterWatts;
  final double evWatts;
  final double otherWatts;
  final double unitWatts;
  final double totalWatts;
  final double calculatedAmps;
  final int voltage;
  final List<CodeReference> references;
  final List<String> notes;

  const DemandBreakdown({
    required this.livingAreaM2,
    required this.dwellingUnits,
    required this.method,
    required this.basicWatts,
    required this.heatingDemandWatts,
    required this.acWatts,
    required this.climateWatts,
    required this.rangeDemandWatts,
    required this.dryerWatts,
    required this.waterHeaterWatts,
    required this.evWatts,
    required this.otherWatts,
    required this.unitWatts,
    required this.totalWatts,
    required this.calculatedAmps,
    required this.voltage,
    required this.references,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'living_area_m2': livingAreaM2,
        'dwelling_units': dwellingUnits,
        'method': method,
        'basic_watts': basicWatts.round(),
        'heating_demand_watts': heatingDemandWatts.round(),
        'ac_watts': acWatts.round(),
        'climate_watts_used': climateWatts.round(),
        'range_demand_watts': rangeDemandWatts.round(),
        'dryer_watts': dryerWatts.round(),
        'water_heater_watts': waterHeaterWatts.round(),
        'ev_watts': evWatts.round(),
        'other_watts': otherWatts.round(),
        'unit_watts_8_200': unitWatts.round(),
        'total_watts': totalWatts.round(),
        'calculated_amps': double.parse(calculatedAmps.toStringAsFixed(1)),
        'voltage': voltage,
      };
}

class DemandCalculator {
  /// Charge de base 8-200 : 5000 W / 90 m² + 1000 W par 90 m² additionnels.
  static double basicLoadWatts(double areaM2) {
    if (areaM2 <= 0) return 0;
    if (areaM2 <= 90) return 5000;
    final extraBlocks = ((areaM2 - 90) / 90).ceil();
    return 5000 + extraBlocks * 1000;
  }

  /// 8-106 — chauffage : 100 % des 10 premiers kW + 75 % du reste.
  static double heatingDemand(double connectedWatts) {
    if (connectedWatts <= 0) return 0;
    if (connectedWatts <= 10000) return connectedWatts;
    return 10000 + 0.75 * (connectedWatts - 10000);
  }

  /// 8-200 — cuisinière : 6 kW + 40 % de l'excédent au-dessus de 12 kW.
  static double rangeDemand(double connectedWatts) {
    if (connectedWatts <= 0) return 0;
    if (connectedWatts <= 12000) {
      return 6000 < connectedWatts ? 6000 : connectedWatts;
    }
    return 6000 + 0.40 * (connectedWatts - 12000);
  }

  /// 8-202 : 100 % de la plus grande charge + 65 % des autres.
  static double largestPlus65(Iterable<double> values) {
    final list = values.where((w) => w > 0).toList()
      ..sort((a, b) => b.compareTo(a));
    if (list.isEmpty) return 0;
    var total = list.first;
    for (var i = 1; i < list.length; i++) {
      total += 0.65 * list[i];
    }
    return total;
  }

  static DemandBreakdown calculate(ProjectInput input) {
    final refs = <CodeReference>[
      const CodeReference(
        rule: '8-200',
        table: '',
        description:
            'Charge calculée d\'une unité d\'habitation — charge de base 5000 W / 90 m².',
      ),
      const CodeReference(
        rule: '8-106',
        table: '',
        description:
            'Facteurs de demande — chauffage 100 % / 10 kW + 75 % du reste ; climatisation vs chauffage.',
      ),
      const CodeReference(
        rule: '8-104',
        table: '',
        description:
            'Charges continues — 125 % pour le calibre des conducteurs et de la protection.',
      ),
    ];
    final notes = <String>[];
    final area = input.livingAreaM2 ?? 0;
    final units = input.dwellingUnits < 1 ? 1 : input.dwellingUnits;

    final unitBasic = basicLoadWatts(area);
    final unitHeatConnected =
        (input.heatingType == HeatingType.electric ||
                input.heatingType == HeatingType.heatPump)
            ? (input.heatingWatts ?? 0)
            : 0.0;
    final unitRange = rangeDemand(input.rangeWatts ?? 0);
    final unitDryer = input.dryerWatts ?? 0;
    final unitWh = input.waterHeaterWatts ?? 0;
    final unitAc = input.acWatts ?? 0;
    var unitEv = 0.0;
    final evConnected = input.evWattsResolved ?? 0;
    if (evConnected > 0) {
      refs.add(const CodeReference(
        rule: '86 / déclaration de travaux',
        table: '',
        description:
            'Charge VÉ incluse au calcul. EMS : retenir la charge gérée. Ancienne méthode QC éliminée (2026).',
      ));
      if (input.evEnergyManagement == true) {
        unitEv = input.evManagedWatts ?? 0;
        notes.add(
          'VÉ avec EMS : $unitEv W alloués au calcul (pas la plaque $evConnected W).',
        );
      } else {
        unitEv = evConnected;
        notes.add(
          'VÉ sans EMS : 100 % de la charge nominale ($evConnected W) ajoutée.',
        );
      }
    }

    var unitOther = 0.0;
    var houseOther = 0.0;
    for (final load in _allLoads(input)) {
      if (load.watts < 1500) continue;
      if (load.onSubpanel) {
        houseOther += load.watts;
      } else {
        unitOther += load.watts;
      }
    }

    final unitHeatDemand = heatingDemand(unitHeatConnected);
    final unitClimate = unitHeatDemand >= unitAc ? unitHeatDemand : unitAc;
    final unitTotal = unitBasic +
        unitClimate +
        unitRange +
        unitDryer +
        unitWh +
        unitEv +
        unitOther;

    late final double basic;
    late final double climate;
    late final double range;
    late final double dryer;
    late final double wh;
    late final double ev;
    late final double other;
    late final String method;

    if (units == 1) {
      method = '8-200';
      basic = unitBasic;
      climate = unitClimate;
      range = unitRange;
      dryer = unitDryer;
      wh = unitWh;
      ev = unitEv;
      other = unitOther + houseOther;
    } else {
      method = '8-202';
      refs.add(const CodeReference(
        rule: '8-202',
        table: '',
        description:
            'Deux logements ou plus : 100 % de la plus grande charge d\'unité (8-200) + 65 % des autres ; chauffage du bâtiment selon 8-106.',
      ));
      final basics = List<double>.filled(units, unitBasic);
      final ranges = List<double>.filled(units, unitRange);
      final dryers = List<double>.filled(units, unitDryer);
      final whs = List<double>.filled(units, unitWh);
      final evs = List<double>.filled(units, unitEv);
      final others = List<double>.filled(units, unitOther);
      basic = largestPlus65(basics);
      range = largestPlus65(ranges);
      dryer = largestPlus65(dryers);
      wh = largestPlus65(whs);
      ev = evs.fold<double>(0, (a, b) => a + b);
      other = largestPlus65(others) + houseOther;
      final buildingHeat = heatingDemand(unitHeatConnected * units);
      final buildingAc = unitAc * units;
      climate = buildingHeat >= buildingAc ? buildingHeat : buildingAc;
      notes.add(
        '8-202 : logements identiques ($units). Charge d\'unité 8-200 = ${unitTotal.round()} W. '
        'Diversité 100 % + 65 % sur base, cuisinières, sécheuses, chauffe-eau. '
        'Chauffage : 8-106 sur le total raccordé (${(unitHeatConnected * units).round()} W).',
      );
    }

    if (unitHeatDemand > 0 && unitAc > 0) {
      notes.add(
        'Chauffage et climatisation : la plus grande des deux demandes est retenue (8-106).',
      );
    }
    if (input.newConstruction && evConnected <= 0) {
      notes.add(
        'Construction neuve : prévoir l\'infrastructure élémentaire VÉ (QC 2026) même si aucune borne n\'est installée maintenant.',
      );
      refs.add(const CodeReference(
        rule: 'QC 2026 — infrastructure VÉ',
        table: '',
        description:
            'Obligation de prévoir l\'infrastructure élémentaire de recharge pour logements dès la construction.',
      ));
    }

    final total = basic + climate + range + dryer + wh + ev + other;
    final volts = input.systemVoltage;
    final amps = volts == 0 ? 0.0 : total / volts;

    return DemandBreakdown(
      livingAreaM2: area,
      dwellingUnits: units,
      method: method,
      basicWatts: basic,
      heatingDemandWatts: units == 1 ? unitHeatDemand : heatingDemand(unitHeatConnected * units),
      acWatts: units == 1 ? unitAc : unitAc * units,
      climateWatts: climate,
      rangeDemandWatts: range,
      dryerWatts: dryer,
      waterHeaterWatts: wh,
      evWatts: ev,
      otherWatts: other,
      unitWatts: unitTotal,
      totalWatts: total,
      calculatedAmps: amps,
      voltage: volts,
      references: refs,
      notes: notes,
    );
  }

  static List<LoadInput> _allLoads(ProjectInput input) {
    return [
      ...input.loads,
      ...input.subPanels.expand((s) => s.loads),
    ];
  }
}
