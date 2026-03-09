import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(const QueensGambitApp());
}

class QueensGambitApp extends StatelessWidget {
  const QueensGambitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Queen's Gambit",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const StartScreen(),
    );
  }
}
