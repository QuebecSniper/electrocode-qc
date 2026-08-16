enum BuildingType {
  residential,
  commercial,
  institutional,
  industrial;

  static BuildingType fromJson(String? value) {
    switch (value) {
      case 'commercial':
        return BuildingType.commercial;
      case 'institutional':
        return BuildingType.institutional;
      case 'industrial':
        return BuildingType.industrial;
      default:
        return BuildingType.residential;
    }
  }

  String get json => name;
}

enum HeatingType {
  none,
  fossil,
  electric,
  heatPump;

  static HeatingType? fromJson(String? value) {
    switch (value) {
      case 'none':
        return HeatingType.none;
      case 'fossil':
        return HeatingType.fossil;
      case 'electric':
        return HeatingType.electric;
      case 'heat_pump':
      case 'heatPump':
        return HeatingType.heatPump;
      default:
        return null;
    }
  }

  String get json {
    switch (this) {
      case HeatingType.heatPump:
        return 'heat_pump';
      default:
        return name;
    }
  }
}

enum ConductorMaterial {
  copper,
  aluminum;

  static ConductorMaterial fromJson(String? value) {
    final v = (value ?? '').toLowerCase();
    if (v.startsWith('al')) return ConductorMaterial.aluminum;
    return ConductorMaterial.copper;
  }

  String get json => this == ConductorMaterial.aluminum ? 'Al' : 'Cu';
  String get labelFr => this == ConductorMaterial.aluminum ? 'aluminium' : 'cuivre';
}

enum ConduitType {
  emt,
  pvc,
  rigid,
  none;

  static ConduitType fromJson(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'pvc':
        return ConduitType.pvc;
      case 'rigid':
      case 'rmc':
        return ConduitType.rigid;
      case 'none':
      case 'cable':
      case 'teck':
      case 'nm':
        return ConduitType.none;
      default:
        return ConduitType.emt;
    }
  }

  String get json => name;
}

enum GroundingElectrode {
  rods,
  plate,
  concreteEncased,
  existingWater,
  municipalWaterNew,
  unknown;

  static GroundingElectrode fromJson(String? value) {
    switch (value) {
      case 'rods':
        return GroundingElectrode.rods;
      case 'plate':
        return GroundingElectrode.plate;
      case 'concrete_encased':
        return GroundingElectrode.concreteEncased;
      case 'existing_water':
        return GroundingElectrode.existingWater;
      case 'municipal_water_new':
        return GroundingElectrode.municipalWaterNew;
      default:
        return GroundingElectrode.unknown;
    }
  }

  String get json {
    switch (this) {
      case GroundingElectrode.concreteEncased:
        return 'concrete_encased';
      case GroundingElectrode.existingWater:
        return 'existing_water';
      case GroundingElectrode.municipalWaterNew:
        return 'municipal_water_new';
      default:
        return name;
    }
  }
}

enum ComplianceStatus {
  conforme,
  nonConforme,
  questionsEnAttente;

  String get json {
    switch (this) {
      case ComplianceStatus.conforme:
        return 'conforme';
      case ComplianceStatus.nonConforme:
        return 'non_conforme';
      case ComplianceStatus.questionsEnAttente:
        return 'questions_en_attente';
    }
  }
}
