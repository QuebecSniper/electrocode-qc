import '../models/calculation_result.dart';
import '../models/enums.dart';
import '../tables/code_tables.dart';

class GroundingResult {
  final String electrodeType;
  final String electrodeConductorCu;
  final String bondingConductorCu;
  final bool municipalWaterNewForbidden;
  final bool compliant;
  final List<String> notes;

  const GroundingResult({
    required this.electrodeType,
    required this.electrodeConductorCu,
    required this.bondingConductorCu,
    required this.municipalWaterNewForbidden,
    required this.compliant,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'electrode': electrodeType,
        'grounding_electrode_conductor_cu': electrodeConductorCu,
        'equipment_bonding_conductor_cu': bondingConductorCu,
        'municipal_water_as_new_electrode': municipalWaterNewForbidden,
        'conforme_section_10': compliant,
        'notes': notes,
      };
}

class GroundingCalculator {
  static GroundingResult calculate({
    required GroundingElectrode electrode,
    required String serviceConductorSize,
    required int serviceOcpd,
  }) {
    final gec = GroundingTables.electrodeCopper(serviceConductorSize);
    final ebc = GroundingTables.bondingCopper(serviceOcpd);
    final forbidden = electrode == GroundingElectrode.municipalWaterNew;
    final notes = <String>[
      'Section 10 révisée (C22.10:26) : progression prise de terre → continuité des masses.',
      'Conducteur d\'électrode : art. 10-812 — #6 Cu pour tiges, plaque ou béton (le Tableau 17 n\'est plus un tableau de calibre GEC).',
      'Lier les canalisations métalliques d\'eau du bâtiment (continuité des masses), distinct de la prise de terre.',
    ];
    if (forbidden) {
      notes.add(
        'NON CONFORME QC 2026 : interdiction d\'utiliser la tuyauterie métallique de distribution d\'eau municipale comme NOUVELLE prise de terre. Utiliser tiges, plaque ou électrode enrobée de béton.',
      );
    }
    if (electrode == GroundingElectrode.existingWater) {
      notes.add(
        'Canalisation d\'eau existante : liaison seulement si déjà en place et toujours métallique. Ne pas l\'utiliser comme nouvelle électrode.',
      );
    }
    if (electrode == GroundingElectrode.rods) {
      notes.add('Tiges : deux tiges typiques, espacement et profondeur selon section 10.');
    }

    return GroundingResult(
      electrodeType: electrode.json,
      electrodeConductorCu: gec,
      bondingConductorCu: ebc,
      municipalWaterNewForbidden: forbidden,
      compliant: !forbidden && electrode != GroundingElectrode.unknown,
      notes: notes,
    );
  }

  static List<CodeReference> references() => const [
        CodeReference(
          rule: '10-616',
          table: 'T16',
          description:
              'Conducteur de continuité des masses — selon OCPD ou ampacité du plus gros conducteur non mis à la terre.',
        ),
        CodeReference(
          rule: '10-812',
          table: '',
          description:
              'Conducteur de mise à la terre d\'électrode : au moins #6 Cu pour tiges, plaque ou béton. Le Tableau 17 vise les systèmes à impédance (10-302), pas le GEC.',
        ),
        CodeReference(
          rule: 'QC 2026 section 10',
          table: '',
          description:
              'Interdiction de la conduite d\'eau municipale comme nouvelle prise de terre.',
        ),
      ];
}
