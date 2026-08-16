import 'enums.dart';

class LoadInput {
  final String name;
  final double watts;
  final int voltage;
  final bool continuous;
  final bool onSubpanel;
  final String? subpanelId;

  const LoadInput({
    required this.name,
    required this.watts,
    this.voltage = 240,
    this.continuous = false,
    this.onSubpanel = false,
    this.subpanelId,
  });

  double get amps => voltage == 0 ? 0 : watts / voltage;

  Map<String, dynamic> toJson() => {
        'name': name,
        'watts': watts,
        'voltage': voltage,
        'continuous': continuous,
        'on_subpanel': onSubpanel,
        if (subpanelId != null) 'subpanel_id': subpanelId,
      };

  factory LoadInput.fromJson(Map<String, dynamic> json) {
    return LoadInput(
      name: json['name'] as String? ?? 'charge',
      watts: (json['watts'] as num?)?.toDouble() ?? 0,
      voltage: (json['voltage'] as num?)?.toInt() ?? 240,
      continuous: json['continuous'] as bool? ?? false,
      onSubpanel: json['on_subpanel'] as bool? ?? false,
      subpanelId: json['subpanel_id'] as String?,
    );
  }
}

class SubPanelInput {
  final String id;
  final String name;
  final double feederLengthM;
  final ConductorMaterial material;
  final List<LoadInput> loads;

  const SubPanelInput({
    required this.id,
    required this.name,
    this.feederLengthM = 15,
    this.material = ConductorMaterial.copper,
    this.loads = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'feeder_length_m': feederLengthM,
        'material': material.json,
        'loads': loads.map((e) => e.toJson()).toList(),
      };

  factory SubPanelInput.fromJson(Map<String, dynamic> json) {
    return SubPanelInput(
      id: json['id'] as String? ?? 'sub',
      name: json['name'] as String? ?? 'Sous-panneau',
      feederLengthM: (json['feeder_length_m'] as num?)?.toDouble() ?? 15,
      material: ConductorMaterial.fromJson(json['material'] as String?),
      loads: (json['loads'] as List? ?? [])
          .whereType<Map>()
          .map((e) => LoadInput.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
