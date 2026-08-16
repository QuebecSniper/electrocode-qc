import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

void main() {
  test('Cas A — studio 65 m² : service 100 A conforme (8-200)', () {
    final result = Dimensioner.run(const ProjectInput(
      projectName: 'Studio 65 m²',
      description: 'Petit logement unifamilial',
      voltage: '120/240',
      phases: 1,
      livingAreaM2: 65,
      heatingType: HeatingType.electric,
      heatingWatts: 6000,
      rangeWatts: 12000,
      dryerWatts: 0,
      waterHeaterWatts: 3000,
      evChargerWatts: 0,
      serviceMaterial: ConductorMaterial.copper,
      serviceLengthM: 15,
      groundingElectrode: GroundingElectrode.rods,
      additionalInfo: {'ev_none': true},
    ));
    ResultSchemaValidator.assertValid(result);
    expect(result.complianceStatus, ComplianceStatus.conforme);
    final demand = result.service['demand'] as Map;
    expect(demand['method'], '8-200');
    expect(demand['calculated_amps'], closeTo(83.3, 0.2));
    expect(result.service['minimum_amps_8_200'], 60);
    expect(result.service['selected_amps'], 100);
    expect(result.mainPanel['bus_amps'], 100);
  });

  test('Cas B — logement de duplex 90 m² : 100 A suffisant (8-200 unité)', () {
    final result = Dimensioner.run(const ProjectInput(
      projectName: 'Logement duplex 90 m²',
      description: 'Un logement dans un duplex',
      voltage: '120/240',
      phases: 1,
      livingAreaM2: 90,
      dwellingUnits: 1,
      heatingType: HeatingType.electric,
      heatingWatts: 8000,
      rangeWatts: 12000,
      dryerWatts: 0,
      waterHeaterWatts: 3000,
      evChargerWatts: 0,
      serviceMaterial: ConductorMaterial.copper,
      serviceLengthM: 15,
      groundingElectrode: GroundingElectrode.rods,
      additionalInfo: {'ev_none': true},
    ));
    ResultSchemaValidator.assertValid(result);
    final demand = result.service['demand'] as Map;
    expect(demand['method'], '8-200');
    expect(demand['calculated_amps'], closeTo(91.7, 0.2));
    expect(result.service['minimum_amps_8_200'], 100);
    expect(result.service['selected_amps'], 100);
    expect(result.complianceStatus, ComplianceStatus.conforme);
  });
}
