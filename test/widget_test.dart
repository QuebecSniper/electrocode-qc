import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:electrocode_qc/app.dart';

void main() {
  testWidgets('affiche le titre ÉlectroCode QC', (tester) async {
    await tester.pumpWidget(const ElectroCodeApp());
    expect(find.textContaining('ÉlectroCode'), findsWidgets);
  });

  test('moteur résidentiel accessible depuis l\'app', () {
    final result = Dimensioner.run(const ProjectInput(
      projectName: 'Test UI',
      buildingType: BuildingType.commercial,
    ));
    expect(result.complianceStatus, ComplianceStatus.questionsEnAttente);
    ResultSchemaValidator.assertValid(result);
  });
}
