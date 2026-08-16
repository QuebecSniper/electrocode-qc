import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

import '../helpers/fixtures.dart';

void main() {
  test('borne 60 A sans EMS augmente la demande vs EMS 20 A', () {
    final sans = Dimensioner.run(completeBungalow(
      name: 'VÉ sans EMS',
      evAmps: 60,
      evEms: false,
      amperage: null,
    ));
    final avec = Dimensioner.run(completeBungalow(
      name: 'VÉ avec EMS',
      evAmps: 60,
      evEms: true,
      evManaged: 4800,
      amperage: null,
    ));
    ResultSchemaValidator.assertValid(sans);
    ResultSchemaValidator.assertValid(avec);
    final ampsSans = (sans.service['demand'] as Map)['calculated_amps'] as num;
    final ampsAvec = (avec.service['demand'] as Map)['calculated_amps'] as num;
    expect(ampsSans, greaterThan(ampsAvec));
    expect(sans.codeReferences.any((e) => e.rule.contains('86')), isTrue);
    expect(
      sans.warnings.any((w) => w.contains('sans EMS') || w.contains('100 %')),
      isTrue,
    );
  });
}
