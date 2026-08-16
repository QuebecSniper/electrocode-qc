import '../tables/code_tables.dart';
import 'conductors.dart';

class ConduitPick {
  final String tradeSize;
  final String label;
  final int conductorCount;
  final double fillPercentAllowed;
  final double conductorAreaMm2;
  final String type;

  const ConduitPick({
    required this.tradeSize,
    required this.label,
    required this.conductorCount,
    required this.fillPercentAllowed,
    required this.conductorAreaMm2,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'trade_size': tradeSize,
        'label': label,
        'conductor_count': conductorCount,
        'fill_percent_allowed': (fillPercentAllowed * 100).round(),
        'conductor_area_mm2': double.parse(conductorAreaMm2.toStringAsFixed(1)),
      };
}

class ConduitCalculator {
  static ConduitPick? forConductors({
    required List<ConductorPick> conductors,
    required String type,
  }) {
    if (type == 'none' || conductors.isEmpty) return null;
    var area = 0.0;
    var count = 0;
    for (final c in conductors) {
      final row = AmpacityTables.bySize(c.size);
      if (row == null) continue;
      final qty = c.role.contains('service') || c.role.contains('feeder') ? 3 : 2;
      area += row.areaMm2 * qty;
      count += qty;
    }
    if (count < 3) count = 3;
    final size = ConduitTables.smallestEmt(
      totalConductorAreaMm2: area,
      conductorCount: count,
    );
    if (size == null) return null;
    return ConduitPick(
      tradeSize: size,
      label: ConduitTables.tradeLabel[size] ?? size,
      conductorCount: count,
      fillPercentAllowed: ConduitTables.maxFillPercent(count),
      conductorAreaMm2: area,
      type: type,
    );
  }
}
