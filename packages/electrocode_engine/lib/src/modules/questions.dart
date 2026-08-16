import '../models/calculation_result.dart';
import '../models/enums.dart';
import '../models/project_input.dart';

class QuestionEngine {
  static const _nonResidential =
      "Le dimensionnement commercial, institutionnel ou industriel n'est pas disponible en V1. "
      "Passez le type de bâtiment à « résidentiel » ou attendez le module correspondant.";

  static List<QuestionAsked> missing(ProjectInput input) {
    final out = <QuestionAsked>[];
    String? ans(String id) => input.answers[id];

    if (input.buildingType != BuildingType.residential) {
      out.add(QuestionAsked(
        id: 'building_type_v1',
        question: _nonResidential,
        answer: ans('building_type_v1'),
      ));
      return out;
    }

    void need(String id, String q, bool missing) {
      if (missing) {
        out.add(QuestionAsked(id: id, question: q, answer: ans(id)));
      }
    }

    need(
      'living_area_m2',
      'Quelle est la superficie habitable (m²) du logement ? (art. 8-200)',
      input.livingAreaM2 == null || input.livingAreaM2! <= 0,
    );
    need(
      'heating_type',
      'Quel est le type de chauffage (électrique, thermopompe, fossile, aucun) ?',
      input.heatingType == null,
    );
    final needsHeatWatts = input.heatingType == HeatingType.electric ||
        input.heatingType == HeatingType.heatPump;
    need(
      'heating_watts',
      'Quelle est la charge de chauffage électrique (W), plinthes / fournaise / appoint ?',
      needsHeatWatts && (input.heatingWatts == null || input.heatingWatts! < 0),
    );
    need(
      'range_watts',
      'Y a-t-il une cuisinière électrique ? Si oui, indiquer la puissance (W), sinon 0.',
      input.rangeWatts == null,
    );
    need(
      'dryer_watts',
      'Y a-t-il une sécheuse électrique ? Si oui, indiquer la puissance (W), sinon 0.',
      input.dryerWatts == null,
    );
    need(
      'water_heater_watts',
      'Y a-t-il un chauffe-eau électrique ? Si oui, indiquer la puissance (W), sinon 0.',
      input.waterHeaterWatts == null,
    );
    need(
      'ev_charger',
      'Y a-t-il une borne de recharge VÉ (ou une infrastructure prévue) ? Indiquer les watts ou ampères, ou 0 si aucune.',
      input.evChargerWatts == null &&
          input.evChargerAmps == null &&
          (input.additionalInfo['ev_none'] != true),
    );
    final evPresent = (input.evWattsResolved ?? 0) > 0;
    need(
      'ev_ems',
      'Un système de gestion d\'énergie (EMS / délestage) est-il utilisé pour la borne VÉ ? (oui/non)',
      evPresent && input.evEnergyManagement == null,
    );
    need(
      'ev_managed_watts',
      'Quelle charge VÉ (W) le système de gestion d\'énergie alloue-t-il au calcul ?',
      evPresent &&
          input.evEnergyManagement == true &&
          (input.evManagedWatts == null || input.evManagedWatts! < 0),
    );
    need(
      'service_material',
      'Conducteurs de branchement : cuivre ou aluminium ?',
      input.serviceMaterial == null,
    );
    need(
      'service_length_m',
      'Quelle est la longueur approximative du branchement / feeder principal (m) pour la chute de tension (8-102) ?',
      input.serviceLengthM == null || input.serviceLengthM! <= 0,
    );
    need(
      'grounding_electrode',
      'Quelle prise de terre est prévue (tiges, plaque, béton armé, canalisation d\'eau existante à lier seulement) ? '
          'Une conduite d\'eau municipale ne peut pas servir de NOUVELLE prise de terre (QC 2026, section 10).',
      input.groundingElectrode == GroundingElectrode.unknown,
    );

    for (final sub in input.subPanels) {
      if (sub.feederLengthM <= 0) {
        need(
          'subpanel_${sub.id}_length',
          'Longueur du feeder du sous-panneau « ${sub.name} » (m) ?',
          true,
        );
      }
    }

    return out;
  }

  static bool isComplete(ProjectInput input) => missing(input).isEmpty;
}
