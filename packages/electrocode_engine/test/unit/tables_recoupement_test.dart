import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

void main() {
  test('T2 Cycle 3 — #14/#12/#10/#8 colonnes 75/90, 14-104 séparé', () {
    final t14 = AmpacityTables.bySize('14')!;
    final t8 = AmpacityTables.bySize('8')!;
    expect(t14.cu75, 20);
    expect(t14.cu90, 25);
    expect(t8.cu75, 50);
    expect(t8.cu90, 55);
    expect(AmpacityTables.smallWireLimit('14', ConductorMaterial.copper), 15);
    expect(AmpacityTables.smallWireLimit('12', ConductorMaterial.copper), 20);
    expect(AmpacityTables.smallWireLimit('10', ConductorMaterial.copper), 30);
  });

  test('T4 Cycle 3 — 1000 kcmil Al et #12 Al', () {
    expect(AmpacityTables.bySize('1000')!.al75, 520);
    expect(AmpacityTables.bySize('1000')!.al90, 585);
    expect(AmpacityTables.bySize('12')!.al75, 20);
  });

  test('T16 Cycle 3 — 40 A → #12 Cu', () {
    expect(GroundingTables.bondingCopper(40), '12');
    expect(GroundingTables.bondingCopper(20), '14');
    expect(GroundingTables.bondingCopper(200), '6');
  });

  test('10-812 — GEC #6 Cu, plus de T17 comme calibre', () {
    expect(GroundingTables.electrodeCopper('3/0'), '6');
    expect(GroundingTables.electrodeCopper('14'), '6');
  });

  test('T5A — paliers 65 °C et 75 °C (colonne 90 °C)', () {
    expect(AmpacityTables.ambientFactor(65), 0.65);
    expect(AmpacityTables.ambientFactor(75), 0.50);
    expect(AmpacityTables.ambientFactor(40), 0.91);
  });

  test('T8 et T5C inchangés', () {
    expect(ConduitTables.maxFillPercent(1), 0.53);
    expect(ConduitTables.maxFillPercent(2), 0.31);
    expect(ConduitTables.maxFillPercent(3), 0.40);
    expect(AmpacityTables.groupingFactor(3), 1.0);
    expect(AmpacityTables.groupingFactor(6), 0.80);
    expect(AmpacityTables.groupingFactor(24), 0.70);
  });
}
