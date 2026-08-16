import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

void main() {
  test('données manquantes → questions_en_attente', () {
    final result = Dimensioner.run(const ProjectInput(
      projectName: 'Saisie vocale brute',
      description: 'Je veux changer le panneau',
      buildingType: BuildingType.residential,
    ));
    ResultSchemaValidator.assertValid(result);
    expect(result.complianceStatus, ComplianceStatus.questionsEnAttente);
    expect(result.questionsAsked, isNotEmpty);
    expect(
      result.questionsAsked.any((q) => q.question.contains('superficie')),
      isTrue,
    );
  });

  test('commercial V1 → questions_en_attente module à venir', () {
    final result = Dimensioner.run(const ProjectInput(
      projectName: 'Commerce',
      buildingType: BuildingType.commercial,
      description: 'Restaurant',
    ));
    ResultSchemaValidator.assertValid(result);
    expect(result.complianceStatus, ComplianceStatus.questionsEnAttente);
    expect(result.toJson()['meta']['building_type'], 'commercial');
    expect(
      result.questionsAsked.first.question.toLowerCase(),
      contains('v1'),
    );
  });
}
