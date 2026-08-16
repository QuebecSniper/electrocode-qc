import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

import '../helpers/fixtures.dart';

void main() {
  test('Cas C — #3 Cu forcé sur service 200 A → non_conforme, pas de surclassement', () {
    final result = Dimensioner.run(completeBungalow(
      name: '200 A calibre forcé #3',
      forcedServiceConductorSize: '3',
    ));
    ResultSchemaValidator.assertValid(result);
    expect(result.complianceStatus, ComplianceStatus.nonConforme);
    expect(result.service['selected_amps'], 200);
    expect(result.service['ungrounded_conductor'], '3');
    expect(result.service['conductor_forced'], isTrue);
    expect(result.service['conductor_ampacity_ok'], isFalse);
    expect(result.service['ampacity_table'], 'T2');
    expect(
      result.warnings.any(
        (w) =>
            w.contains('NON CONFORME') &&
            w.contains('T2') &&
            w.contains('3') &&
            w.contains('n\'a pas été surclassé'),
      ),
      isTrue,
    );
    expect(
      result.codeReferences.any((r) => r.table == 'T2'),
      isTrue,
    );
  });

  test('Cas D — #3 Cu forcé, 100 A, 60 m → VD > 3 %, non_conforme', () {
    final result = Dimensioner.run(const ProjectInput(
      projectName: 'VD calibre forcé',
      voltage: '120/240',
      livingAreaM2: 65,
      heatingType: HeatingType.electric,
      heatingWatts: 6000,
      rangeWatts: 12000,
      dryerWatts: 0,
      waterHeaterWatts: 3000,
      evChargerWatts: 0,
      serviceMaterial: ConductorMaterial.copper,
      forcedServiceConductorSize: '3',
      serviceLengthM: 60,
      groundingElectrode: GroundingElectrode.rods,
      additionalInfo: {'ev_none': true},
    ));
    ResultSchemaValidator.assertValid(result);
    expect(result.service['selected_amps'], 100);
    expect(result.service['ungrounded_conductor'], '3');
    expect(result.service['conductor_forced'], isTrue);
    expect((result.voltageDrop['worst_segment_percent'] as num) > 3, isTrue);
    expect(result.complianceStatus, ComplianceStatus.nonConforme);
    expect(
      result.warnings.any(
        (w) =>
            w.contains('chute de tension') &&
            w.contains('8-102') &&
            w.contains('Aucun surclassement'),
      ),
      isTrue,
    );
  });
}
