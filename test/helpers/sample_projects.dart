import 'package:electrocode_engine/electrocode_engine.dart';

ProjectInput sampleBungalow({
  GroundingElectrode electrode = GroundingElectrode.rods,
  double? amperage = 200,
}) {
  return ProjectInput(
    projectName: 'Bungalow QC',
    buildingType: BuildingType.residential,
    description: 'Logement unifamilial Québec',
    voltage: '120/240',
    amperage: amperage,
    phases: 1,
    livingAreaM2: 120,
    dwellingUnits: 1,
    heatingType: HeatingType.electric,
    heatingWatts: 15000,
    acWatts: 0,
    rangeWatts: 12000,
    dryerWatts: 5500,
    waterHeaterWatts: 4500,
    newConstruction: true,
    serviceMaterial: ConductorMaterial.copper,
    serviceLengthM: 20,
    conduitType: ConduitType.emt,
    groundingElectrode: electrode,
    additionalInfo: const {'ev_none': true},
  );
}

ProjectInput sampleIncomplete() {
  return const ProjectInput(
    projectName: 'Incomplet',
    buildingType: BuildingType.residential,
  );
}
