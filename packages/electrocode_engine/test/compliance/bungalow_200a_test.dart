import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

import '../helpers/fixtures.dart';

void main() {
  test('bungalow 120 m² chauffage électrique — service 200 A conforme', () {
    final result = Dimensioner.run(completeBungalow());
    ResultSchemaValidator.assertValid(result);
    expect(result.complianceStatus, ComplianceStatus.conforme);
    expect(result.service['selected_amps'], 200);
    expect((result.service['demand'] as Map)['calculated_amps'], greaterThan(100));
    expect((result.service['demand'] as Map)['calculated_amps'], lessThan(200));
    expect(result.mainPanel['bus_amps'], 200);
    expect(result.conductors, isNotEmpty);
    expect(result.grounding['equipment_bonding_conductor_cu'], '6');
    expect(
      result.codeReferences.map((e) => e.rule),
      containsAll(['8-200', '8-106', '8-102', '10-616', '10-812']),
    );
    expect(result.codeReferences.any((r) => r.table == 'T2'), isTrue);
    expect(result.codeReferences.any((r) => r.table == 'T5A'), isTrue);
    expect(result.codeReferences.any((r) => r.table == 'T8'), isTrue);
    expect(result.codeReferences.any((r) => r.table == 'T16'), isTrue);
    expect(result.codeReferences.any((r) => r.rule == '10-812'), isTrue);
    expect(result.grounding['grounding_electrode_conductor_cu'], '6');
    expect(result.materials, isNotEmpty);
    expect(result.toJson()['meta']['building_type'], 'residential');
  });
}
