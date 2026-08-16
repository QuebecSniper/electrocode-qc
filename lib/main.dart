import 'package:electrocode_engine/electrocode_engine.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('projects');
  await Hive.openBox<String>('settings');
  runApp(const ElectroCodeApp());
}

/// Exposé pour les tests sans Hive.
Widget testApp({CalculationResult? seed}) => const ElectroCodeApp();
