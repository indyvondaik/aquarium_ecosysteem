import 'package:aquarium_ecosysteem/app/app_screen.dart';
import 'package:aquarium_ecosysteem/app/game_host_screen.dart';
import 'package:aquarium_ecosysteem/app/start_screen.dart';
import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReefEcosystemApp extends StatelessWidget {
  const ReefEcosystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koraalrif Rangers',
      debugShowCheckedModeBanner: false,
      theme: ReefTheme.light(),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ref.watch(appScreenProvider);
    // Info en Quiz schermen komen later; voorlopig sturen we ze terug naar
    // start zodat de knoppen op het menu nu nog geen 404 opleveren.
    return switch (screen) {
      AppScreen.ecosystem => const GameHostScreen(),
      AppScreen.start || AppScreen.info || AppScreen.quiz =>
        const StartScreen(),
    };
  }
}
