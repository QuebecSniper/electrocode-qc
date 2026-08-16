import 'constants.dart';
import 'models/calculation_result.dart';
import 'models/enums.dart';
import 'models/project_input.dart';
import 'tables/code_tables.dart';
import 'modules/conduit.dart';
import 'modules/conductors.dart';
import 'modules/demand.dart';
import 'modules/grounding.dart';
import 'modules/intake_parser.dart';
import 'modules/materials.dart';
import 'modules/questions.dart';
import 'modules/service.dart';
import 'modules/voltage_drop.dart';

class Dimensioner {
  /// Point d'entrée unique du moteur. Déterministe, hors-ligne.
  static CalculationResult run(ProjectInput input, {String? freeText}) {
    var data = input;
    if (freeText != null && freeText.trim().isNotEmpty) {
      data = IntakeParser.mergeText(data, freeText);
    }

    final questions = QuestionEngine.missing(data);
    if (questions.isNotEmpty) {
      return CalculationResult(
        projectName: data.projectName,
        buildingType: data.buildingType,
        input: data.toInputJson(),
        questionsAsked: questions,
        service: const {},
        mainPanel: const {},
        subPanels: const [],
        transformers: const [],
        breakers: const [],
        conductors: const [],
        conduits: const [],
        grounding: const {},
        voltageDrop: const {},
        materials: const [],
        codeReferences: [
          const CodeReference(
            rule: 'général',
            table: '',
            description:
                'Données insuffisantes ou module bâtiment non disponible en V1.',
          ),
        ],
        warnings: [
          if (data.buildingType != BuildingType.residential)
            'V1 résidentielle seulement. Commercial / institutionnel / industriel à venir.',
          'Répondez aux questions avant le dimensionnement complet.',
        ],
        complianceStatus: ComplianceStatus.questionsEnAttente,
      );
    }

    final demand = DemandCalculator.calculate(data);
    final material = data.serviceMaterial ?? ConductorMaterial.copper;
    final service = ServiceCalculator.calculate(
      demand: demand,
      material: material,
      requestedAmps: data.amperage,
    );

    final forcedSize = AmpacityTables.normalizeSize(
      data.forcedServiceConductorSize ??
          data.additionalInfo['forced_service_conductor'] as String?,
    );
    final conductorForced = forcedSize != null;

    ConductorPick servicePick;
    if (conductorForced) {
      servicePick = ConductorSizer.evaluateImposed(
            size: forcedSize,
            loadAmps: service.selectedAmps.toDouble(),
            continuous: false,
            material: material,
            role: 'service_entrance',
            voltage: data.systemVoltage,
            ambientC: data.ambientC,
          ) ??
          ConductorPick(
            size: forcedSize,
            material: material,
            requiredAmps: service.selectedAmps.toDouble(),
            allowableAmps: 0,
            insulationTempC: 75,
            ambientFactor: 1,
            groupingFactor: 1,
            role: 'service_entrance',
            voltage: data.systemVoltage,
            circuitAmps: service.selectedAmps,
          );
    } else {
      servicePick = ConductorSizer.sizeFor(
            loadAmps: service.selectedAmps.toDouble(),
            continuous: false,
            material: material,
            role: 'service_entrance',
            voltage: data.systemVoltage,
            ambientC: data.ambientC,
          ) ??
          ConductorPick(
            size: service.conductorSize,
            material: material,
            requiredAmps: service.selectedAmps.toDouble(),
            allowableAmps: service.selectedAmps.toDouble(),
            insulationTempC: 75,
            ambientFactor: 1,
            groupingFactor: 1,
            role: 'service_entrance',
            voltage: data.systemVoltage,
            circuitAmps: service.selectedAmps,
          );
    }

    final skipUpsize = conductorForced ||
        data.additionalInfo['skip_voltage_drop_upsize'] == true;
    final serviceForVd = skipUpsize
        ? servicePick
        : VoltageDropCalculator.upsizeForDrop(
            initial: servicePick,
            lengthM: data.serviceLengthM ?? 15,
            phases: data.phases,
            limitPercent: 3.0,
          );
    final ampacityOk = ConductorSizer.ampacitySufficient(serviceForVd);
    final ampacityTable = AmpacityTables.ampacityTable(material);

    final vdService = VoltageDropCalculator.calculate(
      conductor: serviceForVd,
      lengthM: data.serviceLengthM ?? 15,
      phases: data.phases,
      limitPercent: 3.0,
      role: 'service_or_feeder',
    );

    final grounding = GroundingCalculator.calculate(
      electrode: data.groundingElectrode,
      serviceConductorSize: serviceForVd.size,
      serviceOcpd: service.selectedAmps,
    );

    final breakers = <Map<String, dynamic>>[
      {
        'role': 'main',
        'amps': service.selectedAmps,
        'poles': data.phases == 3 ? 3 : 2,
        'type': 'disjoncteur_principal',
        'notes': 'Calibre de barre / coffret ${service.selectedAmps} A.',
      },
    ];
    final conductors = <ConductorPick>[serviceForVd];
    final extra = <ConductorPick>[];

    void addLoadCircuit({
      required String role,
      required double watts,
      required int voltage,
      required bool continuous,
      int poles = 2,
    }) {
      if (watts <= 0) return;
      final amps = watts / voltage;
      final pick = ConductorSizer.sizeFor(
        loadAmps: amps,
        continuous: continuous,
        material: data.branchMaterial,
        role: role,
        voltage: voltage,
        ambientC: data.ambientC,
      );
      if (pick == null) return;
      final ocpd = BreakerSizer.forCircuit(
        loadAmps: amps,
        continuous: continuous,
        conductorSize: pick.size,
        conductorAllowable: pick.allowableAmps,
      );
      breakers.add({
        'role': role,
        'amps': ocpd,
        'poles': poles,
        'type': 'disjoncteur_branchement_secondaire',
        'load_watts': watts.round(),
        'continuous': continuous,
      });
      conductors.add(pick);
      extra.add(pick);
    }

    addLoadCircuit(
      role: 'cuisiniere',
      watts: data.rangeWatts ?? 0,
      voltage: 240,
      continuous: false,
    );
    addLoadCircuit(
      role: 'secheuse',
      watts: data.dryerWatts ?? 0,
      voltage: 240,
      continuous: false,
    );
    addLoadCircuit(
      role: 'chauffe_eau',
      watts: data.waterHeaterWatts ?? 0,
      voltage: 240,
      continuous: true,
    );
    addLoadCircuit(
      role: 'chauffage',
      watts: data.heatingType == HeatingType.electric ||
              data.heatingType == HeatingType.heatPump
          ? (data.heatingWatts ?? 0)
          : 0,
      voltage: 240,
      continuous: true,
    );
    addLoadCircuit(
      role: 've',
      watts: data.evEnergyManagement == true
          ? (data.evManagedWatts ?? 0)
          : (data.evWattsResolved ?? 0),
      voltage: data.systemVoltage,
      continuous: true,
    );

    final subPanelsJson = <Map<String, dynamic>>[];
    final vdList = <Map<String, dynamic>>[vdService.toJson()];
    var worstDrop = vdService.dropPercent;
    var totalDrop = vdService.dropPercent;

    for (final sub in data.subPanels) {
      var subWatts = sub.loads.fold<double>(0, (a, b) => a + b.watts);
      if (subWatts <= 0) subWatts = 5000;
      final subAmps = subWatts / data.systemVoltage;
      final feeder = ConductorSizer.sizeFor(
            loadAmps: subAmps,
            continuous: true,
            material: sub.material,
            role: 'feeder_${sub.id}',
            voltage: data.systemVoltage,
            ambientC: data.ambientC,
          );
      if (feeder == null) continue;
      final sized = VoltageDropCalculator.upsizeForDrop(
        initial: feeder,
        lengthM: sub.feederLengthM,
        phases: data.phases,
      );
      final vd = VoltageDropCalculator.calculate(
        conductor: sized,
        lengthM: sub.feederLengthM,
        phases: data.phases,
        role: 'feeder_${sub.id}',
      );
      final ocpd = BreakerSizer.forCircuit(
        loadAmps: subAmps,
        continuous: true,
        conductorSize: sized.size,
        conductorAllowable: sized.allowableAmps,
      );
      final bus = BreakerTables.nextPanel(ocpd.toDouble());
      breakers.add({
        'role': 'feeder_${sub.id}',
        'amps': ocpd,
        'poles': 2,
        'type': 'disjoncteur_feeder',
        'subpanel': sub.name,
      });
      conductors.add(sized);
      extra.add(sized);
      subPanelsJson.add({
        'id': sub.id,
        'name': sub.name,
        'connected_watts': subWatts.round(),
        'calculated_amps': double.parse(subAmps.toStringAsFixed(1)),
        'bus_amps': bus,
        'feeder_breaker_amps': ocpd,
        'feeder_conductor': sized.size,
        'material': sized.material.json,
        'length_m': sub.feederLengthM,
      });
      vdList.add(vd.toJson());
      if (vd.dropPercent > worstDrop) worstDrop = vd.dropPercent;
      totalDrop = vdService.dropPercent + vd.dropPercent;
    }

    final conduit = data.conduitType == ConduitType.none
        ? null
        : ConduitCalculator.forConductors(
            conductors: [serviceForVd],
            type: data.conduitType.json,
          );

    final warnings = <String>[
      ...demand.notes,
      ...service.warnings,
      ...grounding.notes.where((n) => n.startsWith('NON CONFORME')),
      ElectroCode.disclaimer,
    ];
    if (!ampacityOk) {
      warnings.add(
        'NON CONFORME : conducteur ${serviceForVd.size} ${material.json} insuffisant '
        '(${serviceForVd.allowableAmps.toStringAsFixed(0)} A admissibles selon $ampacityTable, '
        'colonne 75 °C) pour ${serviceForVd.requiredAmps.toStringAsFixed(0)} A calculés. '
        'Le calibre imposé n\'a pas été surclassé.',
      );
    }
    if (!vdService.compliant) {
      warnings.add(
        conductorForced
            ? 'NON CONFORME : chute de tension ${vdService.dropPercent.toStringAsFixed(2)} % > 3 % '
                '(8-102) avec le calibre imposé ${serviceForVd.size} ${material.json} '
                'sur ${vdService.lengthM.toStringAsFixed(0)} m. Aucun surclassement automatique.'
            : 'Chute de tension service ${vdService.dropPercent.toStringAsFixed(2)} % > 3 % (8-102). '
                'Calibre porté à ${serviceForVd.size}.',
      );
    }
    if (totalDrop > 5.0) {
      warnings.add(
        'Chute de tension cumulée ${totalDrop.toStringAsFixed(2)} % > 5 % (8-102).',
      );
    }
    if (data.amperage != null && data.amperage! + 1e-9 < demand.calculatedAmps) {
      warnings.add(
        'Service existant ${data.amperage!.toStringAsFixed(0)} A inférieur à la charge calculée ${demand.calculatedAmps.toStringAsFixed(1)} A.',
      );
    }

    var status = ComplianceStatus.conforme;
    if (grounding.municipalWaterNewForbidden) {
      status = ComplianceStatus.nonConforme;
    }
    if (!ampacityOk) {
      status = ComplianceStatus.nonConforme;
    }
    if (!vdService.compliant) {
      status = ComplianceStatus.nonConforme;
    }
    if (totalDrop > 5.0) {
      status = ComplianceStatus.nonConforme;
    }
    if (data.amperage != null &&
        data.amperage! + 1e-9 < demand.calculatedAmps &&
        data.amperage! + 1e-9 < service.minimumByArea) {
      status = ComplianceStatus.nonConforme;
    }

    final codeRefs = <CodeReference>[
      ...demand.references,
      ...service.references,
      ...GroundingCalculator.references(),
      const CodeReference(
        rule: '8-102',
        table: '',
        description:
            'Chute de tension : 3 % feeder ou dérivation, 5 % total depuis le service.',
      ),
      const CodeReference(
        rule: '14-104',
        table: '',
        description:
            'Calibre de protection vs ampacité ; next-size-up interdit pour #14/12/10.',
      ),
      const CodeReference(
        rule: '12',
        table: 'T8',
        description: 'Pourcentage maximal de remplissage des canalisations.',
      ),
      const CodeReference(
        rule: '12',
        table: 'T9',
        description: 'Aire interne des canalisations.',
      ),
      const CodeReference(
        rule: '12',
        table: 'T10',
        description: 'Aire des conducteurs isolés pour le calcul de remplissage.',
      ),
      CodeReference(
        rule: '4-004 / 4-006',
        table: ampacityTable,
        description:
            'Ampacité ${material.labelFr} — $ampacityTable, colonne 75 °C.',
      ),
    ];

    final materials = MaterialsBuilder.build(
      input: data,
      demand: demand,
      service: service,
      serviceConductor: serviceForVd,
      grounding: grounding,
      breakers: breakers,
      extraConductors: extra,
      conduitLabel: conduit?.label,
    );

    return CalculationResult(
      projectName: data.projectName,
      buildingType: data.buildingType,
      input: data.toInputJson(),
      questionsAsked: questions,
      service: {
        ...service.toJson(),
        'ungrounded_conductor': serviceForVd.size,
        'identified_conductor': serviceForVd.size,
        'demand': demand.toJson(),
        'conductor_after_voltage_drop': serviceForVd.size,
        'conductor_forced': conductorForced,
        'conductor_ampacity_ok': ampacityOk,
        'ampacity_table': ampacityTable,
      },
      mainPanel: {
        'bus_amps': service.selectedAmps,
        'main_breaker_amps': service.selectedAmps,
        'voltage': data.voltage,
        'phases': data.phases,
        'suggested_spaces': 40,
        'notes':
            'Prévoir AFCI, DDFT, VÉ, chauffage et espaces de réserve. Surveillance EMS permise (6-212 2)).',
      },
      subPanels: subPanelsJson,
      transformers: const [],
      breakers: breakers,
      conductors: conductors.map((e) => e.toJson()).toList(),
      conduits: [if (conduit != null) conduit.toJson()],
      grounding: grounding.toJson(),
      voltageDrop: {
        'segments': vdList,
        'worst_segment_percent': double.parse(worstDrop.toStringAsFixed(2)),
        'cumulative_percent': double.parse(totalDrop.toStringAsFixed(2)),
        'limit_segment_percent': 3.0,
        'limit_total_percent': 5.0,
        'conforme': status != ComplianceStatus.nonConforme ||
            (vdService.compliant && totalDrop <= 5.0),
      },
      materials: materials,
      codeReferences: codeRefs,
      warnings: warnings.where((w) => w != ElectroCode.disclaimer).toList(),
      complianceStatus: status,
    );
  }
}
