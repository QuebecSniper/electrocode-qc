import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

void main() {
  test('duplex — 8-202 simplifié et JSON valide', () {
    final input = ProjectInput(
      projectName: 'Duplex Rosemont',
      description: 'Deux logements',
      livingAreaM2: 85,
      dwellingUnits: 2,
      heatingType: HeatingType.electric,
      heatingWatts: 12000,
      rangeWatts: 12000,
      dryerWatts: 5000,
      waterHeaterWatts: 3000,
      evChargerWatts: 0,
      serviceMaterial: ConductorMaterial.copper,
      serviceLengthM: 18,
      groundingElectrode: GroundingElectrode.rods,
      additionalInfo: {'ev_none': true},
    );
    final result = Dimensioner.run(input);
    ResultSchemaValidator.assertValid(result);
    expect(result.complianceStatus, isNot(ComplianceStatus.questionsEnAttente));
    expect(result.service['demand']['dwelling_units'], 2);
    expect(result.codeReferences.map((e) => e.rule), contains('8-202'));
    expect(result.service['demand']['method'], '8-202');
    expect(result.service['minimum_amps_8_200'], 100);
  });
}
