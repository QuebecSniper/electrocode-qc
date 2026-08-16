import '../models/enums.dart';
import '../models/load_input.dart';
import '../models/project_input.dart';

/// Extraction simple (français québécois) depuis dictée ou texte libre.
class IntakeParser {
  static ProjectInput mergeText(ProjectInput base, String raw) {
    final text = raw.toLowerCase().replaceAll(',', '.');
    var out = base.copyWith(
      description: base.description.isEmpty ? raw.trim() : base.description,
    );

    final area = _firstDouble(text, [
      r'(\d+(?:\.\d+)?)\s*(?:m²|m2|m\^2|mètres carrés|metres carres)',
      r'(\d+(?:\.\d+)?)\s*(?:pi²|pi2|pieds carrés)',
    ]);
    if (area != null) {
      final m2 = text.contains('pi') ? area * 0.092903 : area;
      out = out.copyWith(livingAreaM2: m2);
    }

    final amps = _firstDouble(text, [
      r'(\d+(?:\.\d+)?)\s*(?:a\b|ampères|amperes|amp\b)',
    ]);
    if (amps != null && amps >= 30) {
      out = out.copyWith(amperage: amps);
    }

    if (RegExp(r'\b3(?:\s|-)?ph').hasMatch(text) || text.contains('triphasé')) {
      out = out.copyWith(phases: 3);
    }
    if (text.contains('347/600') || text.contains('347-600')) {
      out = out.copyWith(voltage: '347/600');
    } else if (text.contains('120/208') || text.contains('208')) {
      out = out.copyWith(voltage: '120/208');
    } else if (text.contains('120/240') || text.contains('240')) {
      out = out.copyWith(voltage: '120/240');
    }

    if (text.contains('aluminium') || RegExp(r'\bal\b').hasMatch(text)) {
      out = out.copyWith(serviceMaterial: ConductorMaterial.aluminum);
    } else if (text.contains('cuivre') || RegExp(r'\bcu\b').hasMatch(text)) {
      out = out.copyWith(serviceMaterial: ConductorMaterial.copper);
    }

    if (text.contains('thermopompe') || text.contains('heat pump')) {
      out = out.copyWith(heatingType: HeatingType.heatPump);
    } else if (text.contains('plinthe') ||
        text.contains('chauffage électrique') ||
        text.contains('chauffage electrique') ||
        text.contains('fournaise électrique')) {
      out = out.copyWith(heatingType: HeatingType.electric);
    } else if (text.contains('gaz') ||
        text.contains('mazout') ||
        text.contains('huile')) {
      out = out.copyWith(heatingType: HeatingType.fossil);
    }

    final heat = _labeledWatts(text, [
      'chauffage',
      'plinthes',
      'fournaise',
    ]);
    if (heat != null) out = out.copyWith(heatingWatts: heat);

    final range = _labeledWatts(text, ['cuisinière', 'cuisiniere', 'range']);
    if (range != null) out = out.copyWith(rangeWatts: range);

    final dryer = _labeledWatts(text, ['sécheuse', 'secheuse', 'dryer']);
    if (dryer != null) out = out.copyWith(dryerWatts: dryer);

    final wh = _labeledWatts(text, ['chauffe-eau', 'chauffe eau', 'water heater']);
    if (wh != null) out = out.copyWith(waterHeaterWatts: wh);

    if (text.contains('duplex') || text.contains('deux logements')) {
      out = out.copyWith(dwellingUnits: 2);
    }

    final evAmps = _firstDouble(text, [
      r'borne[^\d]{0,20}(\d+(?:\.\d+)?)\s*a',
      r'vé[^\d]{0,20}(\d+(?:\.\d+)?)\s*a',
      r've[^\d]{0,20}(\d+(?:\.\d+)?)\s*a',
      r'(\d+(?:\.\d+)?)\s*a[^\.]{0,12}borne',
    ]);
    if (evAmps != null) {
      out = out.copyWith(evChargerAmps: evAmps);
    } else if (text.contains('borne') ||
        text.contains('véhicule électrique') ||
        text.contains('vehicule electrique')) {
      out = out.copyWith(evChargerAmps: 40);
    }
    if (text.contains('sans ems') || text.contains('sans gestion')) {
      out = out.copyWith(evEnergyManagement: false);
    } else if (text.contains('ems') ||
        text.contains('gestion d\'énergie') ||
        text.contains('gestion d energie') ||
        text.contains('délestage') ||
        text.contains('delestage')) {
      out = out.copyWith(evEnergyManagement: true);
    }

    final length = _firstDouble(text, [
      r'(\d+(?:\.\d+)?)\s*m(?:ètres|etres)?(?:\s+de)?\s+(?:feeder|branchement|course|longueur)',
      r'longueur[^\d]{0,12}(\d+(?:\.\d+)?)\s*m',
    ]);
    if (length != null) out = out.copyWith(serviceLengthM: length);

    if (text.contains('tiges') || text.contains('ground rod')) {
      out = out.copyWith(groundingElectrode: GroundingElectrode.rods);
    } else if (text.contains('eau municipale') &&
        (text.contains('prise de terre') || text.contains('nouvelle'))) {
      out = out.copyWith(groundingElectrode: GroundingElectrode.municipalWaterNew);
    }

    final sub = RegExp(
      r'sous[- ]panneau[^\d]{0,40}(\d+(?:\.\d+)?)\s*m',
    ).firstMatch(text);
    if (sub != null && out.subPanels.isEmpty) {
      out = out.copyWith(subPanels: [
        SubPanelInput(
          id: 'atelier',
          name: 'Sous-panneau atelier',
          feederLengthM: double.parse(sub.group(1)!),
        ),
      ]);
    }

    return out;
  }

  static double? _labeledWatts(String text, List<String> labels) {
    for (final label in labels) {
      final a = RegExp('$label[^\\d]{0,20}(\\d+(?:\\.\\d+)?)\\s*(?:kw|kW)').firstMatch(text);
      if (a != null) return double.parse(a.group(1)!) * 1000;
      final b = RegExp('$label[^\\d]{0,20}(\\d+(?:\\.\\d+)?)\\s*w').firstMatch(text);
      if (b != null) return double.parse(b.group(1)!);
    }
    return null;
  }

  static double? _firstDouble(String text, List<String> patterns) {
    for (final p in patterns) {
      final m = RegExp(p, caseSensitive: false).firstMatch(text);
      if (m != null) return double.parse(m.group(1)!);
    }
    return null;
  }
}
