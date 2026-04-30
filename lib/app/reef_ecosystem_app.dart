import 'package:aquarium_ecosysteem/app/game_host_screen.dart';
import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:flutter/material.dart';

class ReefEcosystemApp extends StatelessWidget {
  const ReefEcosystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koraalrif Rangers',
      debugShowCheckedModeBanner: false,
      theme: ReefTheme.light(),
      home: const GameHostScreen(),
    );
  }
}
