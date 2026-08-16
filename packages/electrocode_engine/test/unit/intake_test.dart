import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

void main() {
  test('extrait superficie, 200 A, chauffage et borne depuis le français QC', () {
    const text =
        'Bungalow 120 m² à Laval, service 200 ampères cuivre, '
        'chauffage électrique 15 kW, borne 60 A sans EMS, longueur 25 m, tiges.';
    final parsed = IntakeParser.mergeText(const ProjectInput(), text);
    expect(parsed.livingAreaM2, 120);
    expect(parsed.amperage, 200);
    expect(parsed.heatingType, HeatingType.electric);
    expect(parsed.heatingWatts, 15000);
    expect(parsed.evChargerAmps, 60);
    expect(parsed.evEnergyManagement, false);
    expect(parsed.serviceMaterial, ConductorMaterial.copper);
    expect(parsed.serviceLengthM, 25);
    expect(parsed.groundingElectrode, GroundingElectrode.rods);
  });
}
