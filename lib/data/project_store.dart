import 'dart:convert';

import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class StoredProject {
  final String id;
  final ProjectInput input;
  final String? lastJson;
  final DateTime updatedAt;

  StoredProject({
    required this.id,
    required this.input,
    this.lastJson,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'input': {
          'project_name': input.projectName,
          'building_type': input.buildingType.json,
          'description': input.description,
          'voltage': input.voltage,
          'amperage': input.amperage,
          'phases': input.phases,
          'living_area_m2': input.livingAreaM2,
          'dwelling_units': input.dwellingUnits,
          'heating_type': input.heatingType?.json,
          'heating_watts': input.heatingWatts,
          'ac_watts': input.acWatts,
          'range_watts': input.rangeWatts,
          'dryer_watts': input.dryerWatts,
          'water_heater_watts': input.waterHeaterWatts,
          'ev_charger_watts': input.evChargerWatts,
          'ev_charger_amps': input.evChargerAmps,
          'ev_energy_management': input.evEnergyManagement,
          'ev_managed_watts': input.evManagedWatts,
          'new_construction': input.newConstruction,
          'service_material': input.serviceMaterial?.json,
          'forced_service_conductor': input.forcedServiceConductorSize,
          'service_length_m': input.serviceLengthM,
          'conduit_type': input.conduitType.json,
          'grounding_electrode': input.groundingElectrode.json,
          'loads': input.loads.map((e) => e.toJson()).toList(),
          'sub_panels': input.subPanels.map((e) => e.toJson()).toList(),
          'additional_info': input.additionalInfo,
          'answers': input.answers,
        },
        'last_json': lastJson,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory StoredProject.fromJson(Map<String, dynamic> json) {
    return StoredProject(
      id: json['id'] as String,
      input: ProjectInput.fromJson(
        Map<String, dynamic>.from(json['input'] as Map),
      ),
      lastJson: json['last_json'] as String?,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class ProjectStore {
  static const _boxName = 'projects';

  bool get _ready => Hive.isBoxOpen(_boxName);

  Box<String> get _box => Hive.box<String>(_boxName);

  List<StoredProject> all() {
    if (!_ready) return [];
    final items = _box.values
        .map((raw) => StoredProject.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            ))
        .toList();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  Future<StoredProject> create({String name = 'Nouveau projet'}) async {
    final project = StoredProject(
      id: const Uuid().v4(),
      input: ProjectInput(projectName: name),
    );
    await save(project);
    return project;
  }

  Future<void> save(StoredProject project) async {
    if (!_ready) return;
    await _box.put(project.id, jsonEncode(project.toJson()));
  }

  Future<void> delete(String id) async {
    if (!_ready) return;
    await _box.delete(id);
  }
}
