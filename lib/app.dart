import 'package:flutter/material.dart';

import 'ui/home_screen.dart';
import 'ui/theme.dart';

class ElectroCodeApp extends StatelessWidget {
  const ElectroCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ÉlectroCode QC',
      debugShowCheckedModeBanner: false,
      theme: ElectroTheme.light(),
      home: const HomeScreen(),
    );
  }
}
