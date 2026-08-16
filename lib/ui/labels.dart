import 'package:electrocode_engine/electrocode_engine.dart';

/// Libellés français — couche UI seulement, aucun calcul.
class FieldLabels {
  static String building(BuildingType t) {
    switch (t) {
      case BuildingType.residential:
        return 'Résidentiel';
      case BuildingType.commercial:
        return 'Commercial (V1 : non calculé)';
      case BuildingType.institutional:
        return 'Institutionnel (V1 : non calculé)';
      case BuildingType.industrial:
        return 'Industriel (V1 : non calculé)';
    }
  }

  static String heating(HeatingType t) {
    switch (t) {
      case HeatingType.none:
        return 'Aucun';
      case HeatingType.fossil:
        return 'Fossile';
      case HeatingType.electric:
        return 'Électrique';
      case HeatingType.heatPump:
        return 'Thermopompe';
    }
  }

  static String electrode(GroundingElectrode t) {
    switch (t) {
      case GroundingElectrode.rods:
        return 'Tiges';
      case GroundingElectrode.plate:
        return 'Plaque';
      case GroundingElectrode.concreteEncased:
        return 'Électrode enrobée de béton';
      case GroundingElectrode.existingWater:
        return 'Liaison eau existante seulement';
      case GroundingElectrode.municipalWaterNew:
        return 'Eau municipale (interdit 2026)';
      case GroundingElectrode.unknown:
        return 'Non choisi';
    }
  }

  static String status(ComplianceStatus s) {
    switch (s) {
      case ComplianceStatus.conforme:
        return 'CONFORME';
      case ComplianceStatus.nonConforme:
        return 'NON CONFORME';
      case ComplianceStatus.questionsEnAttente:
        return 'À COMPLÉTER';
    }
  }

  static String statusFromJson(String? raw) {
    switch (raw) {
      case 'conforme':
        return 'CONFORME';
      case 'non_conforme':
        return 'NON CONFORME';
      case 'questions_en_attente':
        return 'À COMPLÉTER';
      default:
        return 'Sans calcul';
    }
  }

  static String formatWhen(DateTime d) {
    final local = d.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${local.year} $hh:$min';
  }
}
