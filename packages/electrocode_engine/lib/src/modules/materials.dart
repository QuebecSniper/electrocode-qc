import '../models/calculation_result.dart';
import '../models/project_input.dart';
import 'conductors.dart';
import 'demand.dart';
import 'grounding.dart';
import 'service.dart';

class MaterialsBuilder {
  static List<MaterialItem> build({
    required ProjectInput input,
    required DemandBreakdown demand,
    required ServiceResult service,
    required ConductorPick serviceConductor,
    required GroundingResult grounding,
    required List<Map<String, dynamic>> breakers,
    required List<ConductorPick> extraConductors,
    String? conduitLabel,
  }) {
    final items = <MaterialItem>[];
    items.add(MaterialItem(
      category: 'Service',
      description:
          'Coffret / disjoncteur principal ${service.selectedAmps} A, 120/240 V 1ϕ',
      quantity: 1,
      unit: 'unité',
      notes: 'Hors niveau de crue ; extérieur permis (QC 2026).',
    ));
    items.add(MaterialItem(
      category: 'Panneau',
      description:
          'Panneau principal barre ${service.selectedAmps} A, 40+ espaces suggérés',
      quantity: 1,
      unit: 'unité',
      notes: 'Prévoir espaces AFCI/GFCI, VÉ et EMS (6-212 2)).',
    ));
    items.add(MaterialItem(
      category: 'Conducteurs',
      description:
          'Branchement ${serviceConductor.size} ${serviceConductor.material.json} (2 non mis à la terre + 1 identifié)',
      quantity: (input.serviceLengthM ?? 15) * 3,
      unit: 'm',
      notes: 'RW90 ou équivalent ; vérifer T19.',
    ));
    items.add(MaterialItem(
      category: 'Mise à la terre',
      description:
          'Conducteur d\'électrode ${grounding.electrodeConductorCu} Cu + tiges/plaque selon choix',
      quantity: 1,
      unit: 'ensemble',
      notes: grounding.notes.isEmpty ? '' : grounding.notes.first,
    ));
    items.add(MaterialItem(
      category: 'Mise à la terre',
      description: 'Conducteur de continuité des masses ${grounding.bondingConductorCu} Cu',
      quantity: 10,
      unit: 'm',
      notes: 'Tableau 16 — selon OCPD ${service.selectedAmps} A.',
    ));

    if ((demand.rangeDemandWatts) > 0 || (input.rangeWatts ?? 0) > 0) {
      items.add(const MaterialItem(
        category: 'Circuit',
        description: 'Circuit cuisinière 40/50 A — 6 Cu 40 °C/75 °C selon calibre retenu',
        quantity: 1,
        unit: 'circuit',
        notes: '26-744 / 8-200.',
      ));
    }
    if ((input.dryerWatts ?? 0) > 0) {
      items.add(const MaterialItem(
        category: 'Circuit',
        description: 'Circuit sécheuse 30 A 120/240 V',
        quantity: 1,
        unit: 'circuit',
        notes: '26-744.',
      ));
    }
    if ((input.waterHeaterWatts ?? 0) > 0) {
      items.add(const MaterialItem(
        category: 'Circuit',
        description: 'Circuit chauffe-eau (charge continue 125 %)',
        quantity: 1,
        unit: 'circuit',
        notes: '8-104.',
      ));
    }
    if ((demand.heatingDemandWatts) > 0) {
      final circuits = (demand.heatingDemandWatts / (240 * 16)).ceil().clamp(1, 40);
      items.add(MaterialItem(
        category: 'Circuit',
        description: 'Circuits de chauffage électrique 20/30 A 240 V',
        quantity: circuits.toDouble(),
        unit: 'circuit',
        notes: 'Charge continue 125 %. Commande près lavabo : assouplissement QC 2026.',
      ));
    }
    if ((demand.evWatts) > 0) {
      items.add(const MaterialItem(
        category: 'VÉ',
        description: 'Circuit borne de recharge + protection dédiée',
        quantity: 1,
        unit: 'circuit',
        notes: 'Déclarer la charge VÉ et la méthode de gestion (QC 2026).',
      ));
    }
    if (input.newConstruction) {
      items.add(const MaterialItem(
        category: 'VÉ',
        description: 'Infrastructure élémentaire de recharge (conduit + conducteurs ou cheminement)',
        quantity: 1,
        unit: 'ensemble',
        notes: 'Obligatoire dès la construction pour logements (QC 2026).',
      ));
    }
    items.add(const MaterialItem(
      category: 'Prises',
      description: 'Prises à obturateurs (tamper-resistant) là où des enfants peuvent être présents',
      quantity: 1,
      unit: 'lot',
      notes: 'QC 2026 — tous les emplacements visés, pas seulement les chambres.',
    ));
    items.add(MaterialItem(
      category: 'Protection',
      description: 'Disjoncteurs AFCI / DDFT selon pièces',
      quantity: breakers.length.toDouble().clamp(1, 80),
      unit: 'unité',
      notes: 'Clarification AFCI circuits existants (QC 2026).',
    ));
    if (conduitLabel != null) {
      items.add(MaterialItem(
        category: 'Canalisation',
        description: 'EMT/PVC $conduitLabel pour feeder/service',
        quantity: input.serviceLengthM ?? 15,
        unit: 'm',
        notes: 'Remplissage T8 ≤ 40 % si ≥ 3 conducteurs.',
      ));
    }
    for (final c in extraConductors) {
      items.add(MaterialItem(
        category: 'Conducteurs',
        description: '${c.role} ${c.size} ${c.material.json}',
        quantity: 1,
        unit: 'circuit',
        notes: 'Ampacité admissible ${c.allowableAmps.toStringAsFixed(0)} A.',
      ));
    }
    for (final sub in input.subPanels) {
      items.add(MaterialItem(
        category: 'Panneau',
        description: 'Sous-panneau ${sub.name}',
        quantity: 1,
        unit: 'unité',
        notes: 'Feeder ${sub.feederLengthM} m.',
      ));
    }
    return items;
  }
}
