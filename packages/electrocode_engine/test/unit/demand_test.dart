import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:test/test.dart';

void main() {
  test('8-200 charge de base 90 m² et 180 m²', () {
    expect(DemandCalculator.basicLoadWatts(90), 5000);
    expect(DemandCalculator.basicLoadWatts(91), 6000);
    expect(DemandCalculator.basicLoadWatts(180), 6000);
    expect(DemandCalculator.basicLoadWatts(181), 7000);
  });

  test('8-106 chauffage 15 kW', () {
    expect(DemandCalculator.heatingDemand(15000), 13750);
  });

  test('8-200 cuisinière 12 kW et 14 kW', () {
    expect(DemandCalculator.rangeDemand(12000), 6000);
    expect(DemandCalculator.rangeDemand(14000), 6000 + 0.4 * 2000);
  });

  test('8-202 : 100 % de la plus grande + 65 % des autres', () {
    expect(DemandCalculator.largestPlus65([20000, 20000]), 33000);
    expect(DemandCalculator.largestPlus65([10000]), 10000);
  });
}
