import 'dart:convert';
import 'dart:io';

import 'package:electrocode_engine/electrocode_engine.dart';

void main(List<String> args) {
  final result = Dimensioner.run(const ProjectInput(
    projectName: 'Bungalow Laval exemple',
    description: 'Unifamilial 120 m2 chauffage électrique',
    voltage: '120/240',
    amperage: 200,
    phases: 1,
    livingAreaM2: 120,
    heatingType: HeatingType.electric,
    heatingWatts: 15000,
    rangeWatts: 12000,
    dryerWatts: 5500,
    waterHeaterWatts: 4500,
    evChargerWatts: 0,
    serviceMaterial: ConductorMaterial.copper,
    serviceLengthM: 20,
    groundingElectrode: GroundingElectrode.rods,
    additionalInfo: {'ev_none': true},
  ));
  ResultSchemaValidator.assertValid(result);
  final encoded = const JsonEncoder.withIndent('  ').convert(result.toJson());
  if (args.isNotEmpty) {
    File(args.first).writeAsStringSync(encoded);
  } else {
    stdout.writeln(encoded);
  }
}

