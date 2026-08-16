import '../models/enums.dart';

/// Tables de travail — recoupement Cycle 3 (2026-08-15) : voir
/// docs/RECOUPEMENT_TABLES_C22.10-26.md
/// Base T2/T4 : ≤ 3 conducteurs, 30 °C. Colonne 75 °C par défaut (art. 4-006).
/// 14-104 reste dans [smallWireLimit], pas dans les colonnes T2/T4.
class WireRow {
  final String size;
  final double cu75;
  final double cu90;
  final double al75;
  final double al90;
  final double areaMm2;
  final double ohmKmCu75;
  final double ohmKmAl75;

  const WireRow({
    required this.size,
    required this.cu75,
    required this.cu90,
    required this.al75,
    required this.al90,
    required this.areaMm2,
    required this.ohmKmCu75,
    required this.ohmKmAl75,
  });

  double ampacity(ConductorMaterial material, {int tempC = 75}) {
    if (material == ConductorMaterial.aluminum) {
      return tempC >= 90 ? al90 : al75;
    }
    return tempC >= 90 ? cu90 : cu75;
  }

  double ohmsPerKm(ConductorMaterial material) {
    return material == ConductorMaterial.aluminum ? ohmKmAl75 : ohmKmCu75;
  }
}

class AmpacityTables {
  static const List<WireRow> wires = [
    WireRow(size: '14', cu75: 20, cu90: 25, al75: 0, al90: 0, areaMm2: 13.61, ohmKmCu75: 8.45, ohmKmAl75: 13.9),
    WireRow(size: '12', cu75: 25, cu90: 30, al75: 20, al90: 25, areaMm2: 16.77, ohmKmCu75: 5.31, ohmKmAl75: 8.73),
    WireRow(size: '10', cu75: 35, cu90: 40, al75: 30, al90: 35, areaMm2: 23.61, ohmKmCu75: 3.34, ohmKmAl75: 5.49),
    WireRow(size: '8', cu75: 50, cu90: 55, al75: 40, al90: 45, areaMm2: 41.61, ohmKmCu75: 2.11, ohmKmAl75: 3.47),
    WireRow(size: '6', cu75: 65, cu90: 75, al75: 50, al90: 55, areaMm2: 59.74, ohmKmCu75: 1.32, ohmKmAl75: 2.17),
    WireRow(size: '4', cu75: 85, cu90: 95, al75: 65, al90: 75, areaMm2: 84.83, ohmKmCu75: 0.831, ohmKmAl75: 1.37),
    WireRow(size: '3', cu75: 100, cu90: 115, al75: 75, al90: 85, areaMm2: 101.16, ohmKmCu75: 0.659, ohmKmAl75: 1.08),
    WireRow(size: '2', cu75: 115, cu90: 130, al75: 90, al90: 100, areaMm2: 117.94, ohmKmCu75: 0.523, ohmKmAl75: 0.86),
    WireRow(size: '1', cu75: 130, cu90: 145, al75: 100, al90: 115, areaMm2: 156.77, ohmKmCu75: 0.414, ohmKmAl75: 0.68),
    WireRow(size: '1/0', cu75: 150, cu90: 170, al75: 120, al90: 135, areaMm2: 189.67, ohmKmCu75: 0.328, ohmKmAl75: 0.54),
    WireRow(size: '2/0', cu75: 175, cu90: 195, al75: 135, al90: 150, areaMm2: 226.06, ohmKmCu75: 0.261, ohmKmAl75: 0.43),
    WireRow(size: '3/0', cu75: 200, cu90: 225, al75: 155, al90: 175, areaMm2: 270.97, ohmKmCu75: 0.207, ohmKmAl75: 0.34),
    WireRow(size: '4/0', cu75: 230, cu90: 260, al75: 180, al90: 205, areaMm2: 322.58, ohmKmCu75: 0.164, ohmKmAl75: 0.27),
    WireRow(size: '250', cu75: 255, cu90: 290, al75: 205, al90: 230, areaMm2: 396.1, ohmKmCu75: 0.139, ohmKmAl75: 0.228),
    WireRow(size: '300', cu75: 285, cu90: 320, al75: 230, al90: 260, areaMm2: 456.1, ohmKmCu75: 0.116, ohmKmAl75: 0.191),
    WireRow(size: '350', cu75: 310, cu90: 350, al75: 250, al90: 280, areaMm2: 515.0, ohmKmCu75: 0.099, ohmKmAl75: 0.163),
    WireRow(size: '400', cu75: 335, cu90: 380, al75: 270, al90: 305, areaMm2: 571.0, ohmKmCu75: 0.087, ohmKmAl75: 0.143),
    WireRow(size: '500', cu75: 380, cu90: 430, al75: 310, al90: 350, areaMm2: 698.2, ohmKmCu75: 0.070, ohmKmAl75: 0.115),
    WireRow(size: '600', cu75: 420, cu90: 475, al75: 340, al90: 385, areaMm2: 820.5, ohmKmCu75: 0.058, ohmKmAl75: 0.095),
    WireRow(size: '750', cu75: 475, cu90: 535, al75: 385, al90: 435, areaMm2: 1007, ohmKmCu75: 0.047, ohmKmAl75: 0.077),
    WireRow(size: '1000', cu75: 545, cu90: 615, al75: 520, al90: 585, areaMm2: 1297, ohmKmCu75: 0.035, ohmKmAl75: 0.058),
  ];

  /// Art. 14-104 : #14/12/10 limités à 15/20/30 A.
  static double smallWireLimit(String size, ConductorMaterial material) {
    if (material == ConductorMaterial.aluminum) {
      if (size == '12') return 15;
      if (size == '10') return 25;
    } else {
      if (size == '14') return 15;
      if (size == '12') return 20;
      if (size == '10') return 30;
    }
    return double.infinity;
  }

  /// Tableau 5A — correction ambiante, isolation 90 °C, base 30 °C.
  static double ambientFactor(int ambientC) {
    if (ambientC <= 30) return 1.0;
    if (ambientC <= 35) return 0.96;
    if (ambientC <= 40) return 0.91;
    if (ambientC <= 45) return 0.87;
    if (ambientC <= 50) return 0.82;
    if (ambientC <= 55) return 0.76;
    if (ambientC <= 60) return 0.71;
    if (ambientC <= 65) return 0.65;
    if (ambientC <= 70) return 0.58;
    if (ambientC <= 75) return 0.50;
    return 0.41;
  }

  /// Tableau 5C — plus de 3 conducteurs sous tension.
  static double groupingFactor(int currentCarrying) {
    if (currentCarrying <= 3) return 1.0;
    if (currentCarrying <= 6) return 0.80;
    if (currentCarrying <= 24) return 0.70;
    if (currentCarrying <= 42) return 0.60;
    return 0.50;
  }

  static String ampacityTable(ConductorMaterial material) {
    return material == ConductorMaterial.aluminum ? 'T4' : 'T2';
  }

  static String? normalizeSize(String? raw) {
    if (raw == null) return null;
    var s = raw.trim().toUpperCase();
    if (s.isEmpty) return null;
    s = s.replaceAll('#', '').replaceAll('AWG', '').replaceAll('KCMIL', '');
    s = s.replaceAll(' ', '');
    if (s == '0' || s == '1/0' || s == '10') {
      // keep 10 vs 1/0
    }
    if (s == '0' || s == '1-0') s = '1/0';
    if (s == '00' || s == '2-0') s = '2/0';
    if (s == '000' || s == '3-0') s = '3/0';
    if (s == '0000' || s == '4-0') s = '4/0';
    return bySize(s) == null ? null : s;
  }

  static WireRow? bySize(String size) {
    final n = size.trim();
    for (final w in wires) {
      if (w.size == n) return w;
    }
    return null;
  }

  static WireRow? smallestFor({
    required double requiredAmps,
    required ConductorMaterial material,
    int tempC = 75,
    double ambientCorr = 1.0,
    double groupingCorr = 1.0,
  }) {
    for (final w in wires) {
      final base = w.ampacity(material, tempC: tempC);
      if (base <= 0) continue;
      var allowed = base * ambientCorr * groupingCorr;
      final limit = smallWireLimit(w.size, material);
      if (limit.isFinite) {
        allowed = allowed < limit ? allowed : limit;
      }
      if (allowed + 1e-9 >= requiredAmps) return w;
    }
    return null;
  }
}

class BreakerTables {
  static const List<int> standard = [
    15, 20, 25, 30, 35, 40, 45, 50, 60, 70, 80, 90, 100, 110, 125, 150, 175,
    200, 225, 250, 300, 350, 400, 500, 600, 800, 1000, 1200,
  ];

  static const List<int> panelBus = [60, 100, 125, 150, 200, 225, 400, 600];

  static int nextStandard(double amps) {
    for (final s in standard) {
      if (s + 1e-9 >= amps) return s;
    }
    return standard.last;
  }

  static int nextPanel(double amps) {
    for (final s in panelBus) {
      if (s + 1e-9 >= amps) return s;
    }
    return panelBus.last;
  }

  /// 14-104 : next-size-up interdit pour #14, #12, #10.
  static bool nextSizeUpAllowed(String conductorSize) {
    return conductorSize != '14' &&
        conductorSize != '12' &&
        conductorSize != '10';
  }
}

class GroundingTables {
  /// Tableau 16 — conducteur de continuité des masses (cuivre) selon OCPD.
  static String bondingCopper(int ocpdAmps) {
    if (ocpdAmps <= 20) return '14';
    if (ocpdAmps <= 40) return '12';
    if (ocpdAmps <= 60) return '10';
    if (ocpdAmps <= 100) return '8';
    if (ocpdAmps <= 200) return '6';
    if (ocpdAmps <= 300) return '4';
    if (ocpdAmps <= 400) return '3';
    if (ocpdAmps <= 500) return '2';
    if (ocpdAmps <= 600) return '1';
    if (ocpdAmps <= 800) return '1/0';
    if (ocpdAmps <= 1000) return '2/0';
    if (ocpdAmps <= 1200) return '3/0';
    return '4/0';
  }

  /// Conducteur d'électrode — art. 10-812 (C22.10:26 / CCÉ 25e).
  /// Le Tableau 17 n'est plus un tableau de calibre GEC : il concerne
  /// les systèmes mis à la terre par impédance (art. 10-302).
  /// Pour tiges / plaque / béton : #6 Cu, pas plus gros requis.
  static String electrodeCopper(String ungroundedSize) {
    // 10-812 : tiges/plaque/béton → #6 Cu, indépendant du calibre de phase.
    return ungroundedSize.isEmpty ? '6' : '6';
  }
}

class ConduitTables {
  /// Aires internes de travail (série EMT-like). L'officiel C22.10:26 est
  /// T9A–T9P (EMT = 9I) et T10A–T10D — voir recoupement Cycle 3.
  static const Map<String, double> emtInternalMm2 = {
    '16': 204,
    '21': 366,
    '27': 599,
    '35': 1033,
    '41': 1410,
    '53': 2323,
    '63': 3319,
    '78': 5101,
    '91': 6832,
    '103': 8795,
  };

  static const Map<String, String> tradeLabel = {
    '16': '16 (1/2 po)',
    '21': '21 (3/4 po)',
    '27': '27 (1 po)',
    '35': '35 (1-1/4 po)',
    '41': '41 (1-1/2 po)',
    '53': '53 (2 po)',
    '63': '63 (2-1/2 po)',
    '78': '78 (3 po)',
    '91': '91 (3-1/2 po)',
    '103': '103 (4 po)',
  };

  /// Tableau 8 : 40 % si ≥ 3 conducteurs.
  static double maxFillPercent(int conductorCount) {
    if (conductorCount <= 1) return 0.53;
    if (conductorCount == 2) return 0.31;
    return 0.40;
  }

  static String? smallestEmt({
    required double totalConductorAreaMm2,
    required int conductorCount,
  }) {
    final fill = maxFillPercent(conductorCount);
    final needed = totalConductorAreaMm2 / fill;
    final sizes = emtInternalMm2.keys.toList()
      ..sort((a, b) => emtInternalMm2[a]!.compareTo(emtInternalMm2[b]!));
    for (final s in sizes) {
      if (emtInternalMm2[s]! + 1e-9 >= needed) return s;
    }
    return null;
  }
}
