import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:electrocode_qc/ui/questions_screen.dart';
import 'package:electrocode_qc/ui/result_screen.dart';

import 'helpers/sample_projects.dart';

void main() {
  testWidgets('flux incomplet → questions en français, Continuer désactivé',
      (tester) async {
    final input = sampleIncomplete();
    final result = Dimensioner.run(input);
    expect(result.complianceStatus, ComplianceStatus.questionsEnAttente);

    await tester.pumpWidget(
      MaterialApp(
        home: QuestionsScreen(input: input, result: result),
      ),
    );

    expect(find.textContaining('superficie'), findsWidgets);
    expect(find.text('living_area_m2'), findsNothing);
    expect(find.text('Continuer'), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('flux complet → résultat CONFORME + disclaimer', (tester) async {
    final result = Dimensioner.run(sampleBungalow());
    expect(result.complianceStatus, ComplianceStatus.conforme);

    await tester.pumpWidget(MaterialApp(home: ResultScreen(result: result)));

    expect(find.text('CONFORME'), findsOneWidget);
    expect(find.text('NON CONFORME'), findsNothing);
    expect(
      find.textContaining('responsabilité finale appartient'),
      findsOneWidget,
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -800));
    await tester.pump();
    expect(find.textContaining('Liste de matériel'), findsOneWidget);
  });

  testWidgets('eau municipale nouvelle → NON CONFORME + avertissement',
      (tester) async {
    final result = Dimensioner.run(
      sampleBungalow(electrode: GroundingElectrode.municipalWaterNew),
    );
    expect(result.complianceStatus, ComplianceStatus.nonConforme);

    await tester.pumpWidget(MaterialApp(home: ResultScreen(result: result)));

    expect(find.text('NON CONFORME'), findsOneWidget);
    expect(find.text('CONFORME'), findsNothing);
    expect(find.textContaining('Avertissements'), findsOneWidget);
    expect(
      find.textContaining('responsabilité finale appartient'),
      findsOneWidget,
    );
  });
}
