import 'enums.dart';
import 'load_input.dart';

class ProjectInput {
  final String projectName;
  final BuildingType buildingType;
  final String description;
  final String voltage;
  final double? amperage;
  final int phases;
  final double? livingAreaM2;
  final int dwellingUnits;
  final HeatingType? heatingType;
  final double? heatingWatts;
  final double? acWatts;
  final double? rangeWatts;
  final double? dryerWatts;
  final double? waterHeaterWatts;
  final double? evChargerWatts;
  final double? evChargerAmps;
  final bool? evEnergyManagement;
  final double? evManagedWatts;
  final bool newConstruction;
  final ConductorMaterial? serviceMaterial;
  final String? forcedServiceConductorSize;
  final ConductorMaterial branchMaterial;
  final double? serviceLengthM;
  final ConduitType conduitType;
  final int ambientC;
  final int extraConductorsInRaceway;
  final GroundingElectrode groundingElectrode;
  final bool existingWaterPipeBondingOnly;
  final List<LoadInput> loads;
  final List<SubPanelInput> subPanels;
  final Map<String, String?> answers;
  final Map<String, dynamic> additionalInfo;

  const ProjectInput({
    this.projectName = 'Projet',
    this.buildingType = BuildingType.residential,
    this.description = '',
    this.voltage = '120/240',
    this.amperage,
    this.phases = 1,
    this.livingAreaM2,
    this.dwellingUnits = 1,
    this.heatingType,
    this.heatingWatts,
    this.acWatts,
    this.rangeWatts,
    this.dryerWatts,
    this.waterHeaterWatts,
    this.evChargerWatts,
    this.evChargerAmps,
    this.evEnergyManagement,
    this.evManagedWatts,
    this.newConstruction = true,
    this.serviceMaterial,
    this.forcedServiceConductorSize,
    this.branchMaterial = ConductorMaterial.copper,
    this.serviceLengthM,
    this.conduitType = ConduitType.emt,
    this.ambientC = 30,
    this.extraConductorsInRaceway = 0,
    this.groundingElectrode = GroundingElectrode.unknown,
    this.existingWaterPipeBondingOnly = false,
    this.loads = const [],
    this.subPanels = const [],
    this.answers = const {},
    this.additionalInfo = const {},
  });

  int get systemVoltage {
    if (voltage.contains('600')) return phases == 3 ? 600 : 600;
    if (voltage.contains('347')) return 347;
    if (voltage.contains('208')) return 208;
    if (voltage.contains('240')) return 240;
    return 240;
  }

  double? get evWattsResolved {
    if (evChargerWatts != null) return evChargerWatts;
    if (evChargerAmps != null) return evChargerAmps! * systemVoltage.toDouble();
    return null;
  }

  ProjectInput copyWith({
    String? projectName,
    BuildingType? buildingType,
    String? description,
    String? voltage,
    double? amperage,
    int? phases,
    double? livingAreaM2,
    int? dwellingUnits,
    HeatingType? heatingType,
    double? heatingWatts,
    double? acWatts,
    double? rangeWatts,
    double? dryerWatts,
    double? waterHeaterWatts,
    double? evChargerWatts,
    double? evChargerAmps,
    bool? evEnergyManagement,
    double? evManagedWatts,
    bool? newConstruction,
    ConductorMaterial? serviceMaterial,
    String? forcedServiceConductorSize,
    ConductorMaterial? branchMaterial,
    double? serviceLengthM,
    ConduitType? conduitType,
    int? ambientC,
    int? extraConductorsInRaceway,
    GroundingElectrode? groundingElectrode,
    bool? existingWaterPipeBondingOnly,
    List<LoadInput>? loads,
    List<SubPanelInput>? subPanels,
    Map<String, String?>? answers,
    Map<String, dynamic>? additionalInfo,
  }) {
    return ProjectInput(
      projectName: projectName ?? this.projectName,
      buildingType: buildingType ?? this.buildingType,
      description: description ?? this.description,
      voltage: voltage ?? this.voltage,
      amperage: amperage ?? this.amperage,
      phases: phases ?? this.phases,
      livingAreaM2: livingAreaM2 ?? this.livingAreaM2,
      dwellingUnits: dwellingUnits ?? this.dwellingUnits,
      heatingType: heatingType ?? this.heatingType,
      heatingWatts: heatingWatts ?? this.heatingWatts,
      acWatts: acWatts ?? this.acWatts,
      rangeWatts: rangeWatts ?? this.rangeWatts,
      dryerWatts: dryerWatts ?? this.dryerWatts,
      waterHeaterWatts: waterHeaterWatts ?? this.waterHeaterWatts,
      evChargerWatts: evChargerWatts ?? this.evChargerWatts,
      evChargerAmps: evChargerAmps ?? this.evChargerAmps,
      evEnergyManagement: evEnergyManagement ?? this.evEnergyManagement,
      evManagedWatts: evManagedWatts ?? this.evManagedWatts,
      newConstruction: newConstruction ?? this.newConstruction,
      serviceMaterial: serviceMaterial ?? this.serviceMaterial,
      forcedServiceConductorSize: forcedServiceConductorSize == ''
          ? null
          : (forcedServiceConductorSize ?? this.forcedServiceConductorSize),
      branchMaterial: branchMaterial ?? this.branchMaterial,
      serviceLengthM: serviceLengthM ?? this.serviceLengthM,
      conduitType: conduitType ?? this.conduitType,
      ambientC: ambientC ?? this.ambientC,
      extraConductorsInRaceway:
          extraConductorsInRaceway ?? this.extraConductorsInRaceway,
      groundingElectrode: groundingElectrode ?? this.groundingElectrode,
      existingWaterPipeBondingOnly:
          existingWaterPipeBondingOnly ?? this.existingWaterPipeBondingOnly,
      loads: loads ?? this.loads,
      subPanels: subPanels ?? this.subPanels,
      answers: answers ?? this.answers,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  Map<String, dynamic> toInputJson() => {
        'description': description,
        'voltage': voltage,
        'amperage': amperage,
        'phases': phases,
        'loads': [
          ...loads.map((e) => e.toJson()),
          ...subPanels.expand((s) => s.loads.map((e) => e.toJson())),
        ],
        'additional_info': {
          ...additionalInfo,
          'living_area_m2': livingAreaM2,
          'dwelling_units': dwellingUnits,
          'heating_type': heatingType?.json,
          'heating_watts': heatingWatts,
          'ac_watts': acWatts,
          'range_watts': rangeWatts,
          'dryer_watts': dryerWatts,
          'water_heater_watts': waterHeaterWatts,
          'ev_charger_watts': evWattsResolved,
          'ev_energy_management': evEnergyManagement,
          'ev_managed_watts': evManagedWatts,
          'new_construction': newConstruction,
          'service_material': serviceMaterial?.json,
          'forced_service_conductor': forcedServiceConductorSize,
          'branch_material': branchMaterial.json,
          'service_length_m': serviceLengthM,
          'conduit_type': conduitType.json,
          'ambient_c': ambientC,
          'grounding_electrode': groundingElectrode.json,
          'sub_panels': subPanels.map((e) => e.toJson()).toList(),
        },
      };

  factory ProjectInput.fromJson(Map<String, dynamic> json) {
    final additional = Map<String, dynamic>.from(
      json['additional_info'] as Map? ?? json['additionalInfo'] as Map? ?? {},
    );
    final answersRaw = json['answers'] as Map? ?? {};
    return ProjectInput(
      projectName: json['project_name'] as String? ??
          json['projectName'] as String? ??
          'Projet',
      buildingType: BuildingType.fromJson(
        json['building_type'] as String? ?? json['buildingType'] as String?,
      ),
      description: json['description'] as String? ?? '',
      voltage: json['voltage'] as String? ?? '120/240',
      amperage: (json['amperage'] as num?)?.toDouble(),
      phases: (json['phases'] as num?)?.toInt() ?? 1,
      livingAreaM2: (json['living_area_m2'] as num?)?.toDouble() ??
          (additional['living_area_m2'] as num?)?.toDouble(),
      dwellingUnits: (json['dwelling_units'] as num?)?.toInt() ??
          (additional['dwelling_units'] as num?)?.toInt() ??
          1,
      heatingType: HeatingType.fromJson(
        json['heating_type'] as String? ?? additional['heating_type'] as String?,
      ),
      heatingWatts: (json['heating_watts'] as num?)?.toDouble() ??
          (additional['heating_watts'] as num?)?.toDouble(),
      acWatts: (json['ac_watts'] as num?)?.toDouble() ??
          (additional['ac_watts'] as num?)?.toDouble(),
      rangeWatts: (json['range_watts'] as num?)?.toDouble() ??
          (additional['range_watts'] as num?)?.toDouble(),
      dryerWatts: (json['dryer_watts'] as num?)?.toDouble() ??
          (additional['dryer_watts'] as num?)?.toDouble(),
      waterHeaterWatts: (json['water_heater_watts'] as num?)?.toDouble() ??
          (additional['water_heater_watts'] as num?)?.toDouble(),
      evChargerWatts: (json['ev_charger_watts'] as num?)?.toDouble() ??
          (additional['ev_charger_watts'] as num?)?.toDouble(),
      evChargerAmps: (json['ev_charger_amps'] as num?)?.toDouble() ??
          (additional['ev_charger_amps'] as num?)?.toDouble(),
      evEnergyManagement: json['ev_energy_management'] as bool? ??
          additional['ev_energy_management'] as bool?,
      evManagedWatts: (json['ev_managed_watts'] as num?)?.toDouble() ??
          (additional['ev_managed_watts'] as num?)?.toDouble(),
      newConstruction: json['new_construction'] as bool? ??
          additional['new_construction'] as bool? ??
          true,
      serviceMaterial: json['service_material'] != null ||
              additional['service_material'] != null
          ? ConductorMaterial.fromJson(
              json['service_material'] as String? ??
                  additional['service_material'] as String?,
            )
          : null,
      forcedServiceConductorSize: json['forced_service_conductor'] as String? ??
          additional['forced_service_conductor'] as String?,
      branchMaterial: ConductorMaterial.fromJson(
        json['branch_material'] as String? ??
            additional['branch_material'] as String?,
      ),
      serviceLengthM: (json['service_length_m'] as num?)?.toDouble() ??
          (additional['service_length_m'] as num?)?.toDouble(),
      conduitType: ConduitType.fromJson(
        json['conduit_type'] as String? ?? additional['conduit_type'] as String?,
      ),
      ambientC: (json['ambient_c'] as num?)?.toInt() ??
          (additional['ambient_c'] as num?)?.toInt() ??
          30,
      extraConductorsInRaceway:
          (json['extra_conductors'] as num?)?.toInt() ?? 0,
      groundingElectrode: GroundingElectrode.fromJson(
        json['grounding_electrode'] as String? ??
            additional['grounding_electrode'] as String?,
      ),
      loads: (json['loads'] as List? ?? [])
          .whereType<Map>()
          .map((e) => LoadInput.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      subPanels: (json['sub_panels'] as List? ??
              additional['sub_panels'] as List? ??
              [])
          .whereType<Map>()
          .map((e) => SubPanelInput.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      answers: answersRaw.map((k, v) => MapEntry('$k', v?.toString())),
      additionalInfo: additional,
    );
  }
}
