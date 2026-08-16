import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

void main() {
  test('JSON questions_en_attente valide le schéma', () {
    final result = Dimensioner.run(const ProjectInput(projectName: 'Incomplet'));
    ResultSchemaValidator.assertValid(result);
    expect(result.complianceStatus, ComplianceStatus.questionsEnAttente);
    expect(result.toJson()['disclaimer'], ElectroCode.disclaimer);
    expect(result.toJson()['meta']['code_version'], 'C22.10:26');
  });
}
