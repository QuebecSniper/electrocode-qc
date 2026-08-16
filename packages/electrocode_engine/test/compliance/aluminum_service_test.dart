import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

import '../helpers/fixtures.dart';

void main() {
  test('branchement aluminium plus gros que cuivre à 200 A', () {
    final cu = Dimensioner.run(completeBungalow(material: ConductorMaterial.copper));
    final al = Dimensioner.run(completeBungalow(
      name: 'Al',
      material: ConductorMaterial.aluminum,
    ));
    ResultSchemaValidator.assertValid(cu);
    ResultSchemaValidator.assertValid(al);
    expect(cu.service['material'], 'Cu');
    expect(al.service['material'], 'Al');
    final cuSize = cu.service['ungrounded_conductor'] as String;
    final alSize = al.service['ungrounded_conductor'] as String;
    expect(alSize, isNot(equals(cuSize)));
  });
}
