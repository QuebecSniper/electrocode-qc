import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:electrocode_qc/app.dart';

void main() {
  testWidgets('affiche le titre ÉlectroCode QC', (tester) async {
    await tester.pumpWidget(const ElectroCodeApp());
    expect(find.textContaining('ÉlectroCode'), findsWidgets);
    expect(find.textContaining('Aucun chantier'), findsOneWidget);
    expect(
      find.textContaining('responsabilité finale appartient'),
      findsOneWidget,
    );
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
