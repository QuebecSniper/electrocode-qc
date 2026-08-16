import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

import '../helpers/fixtures.dart';

void main() {
  test('sous-panneau atelier 40 m — feeder, VD et disjoncteur', () {
    final result = Dimensioner.run(completeBungalow(
      name: 'Atelier',
      subPanels: [
        SubPanelInput(
          id: 'atelier',
          name: 'Sous-panneau atelier',
          feederLengthM: 40,
          loads: const [
            LoadInput(name: 'soudure', watts: 5000, continuous: false),
            LoadInput(name: 'outils', watts: 3000, continuous: false),
          ],
        ),
      ],
    ));
    ResultSchemaValidator.assertValid(result);
    expect(result.subPanels, isNotEmpty);
    expect(result.subPanels.first['length_m'], 40);
    expect(result.voltageDrop['segments'], isNotEmpty);
    expect(
      result.breakers.any((b) => '${b['role']}'.contains('atelier')),
      isTrue,
    );
  });
}
