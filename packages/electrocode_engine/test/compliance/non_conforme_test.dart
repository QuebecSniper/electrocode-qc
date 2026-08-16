import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

import '../helpers/fixtures.dart';

void main() {
  test('nouvelle prise de terre sur eau municipale → non_conforme', () {
    final result = Dimensioner.run(completeBungalow(
      name: 'Eau municipale',
      electrode: GroundingElectrode.municipalWaterNew,
    ));
    ResultSchemaValidator.assertValid(result);
    expect(result.complianceStatus, ComplianceStatus.nonConforme);
    expect(result.grounding['municipal_water_as_new_electrode'], isTrue);
    expect(result.warnings.any((w) => w.contains('NON CONFORME')), isTrue);
  });

  test('chute de tension excessive sans surclassement → non_conforme', () {
    final result = Dimensioner.run(completeBungalow(
      name: 'VD excessive',
      length: 250,
      amperage: 200,
      additional: {'skip_voltage_drop_upsize': true},
    ));
    ResultSchemaValidator.assertValid(result);
    expect(result.complianceStatus, ComplianceStatus.nonConforme);
    expect((result.voltageDrop['worst_segment_percent'] as num) > 3, isTrue);
  });

  test('service existant 60 A trop petit pour 120 m² → non_conforme', () {
    final result = Dimensioner.run(completeBungalow(
      name: '60 A existant',
      amperage: 60,
    ));
    ResultSchemaValidator.assertValid(result);
    expect(result.warnings.any((w) => w.contains('60')), isTrue);
  });
}
