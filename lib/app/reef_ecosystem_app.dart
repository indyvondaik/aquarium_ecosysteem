import 'package:aquarium_ecosysteem/app/app_screen.dart';
import 'package:aquarium_ecosysteem/app/game_host_screen.dart';
import 'package:aquarium_ecosysteem/app/start_screen.dart';
import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/info_aquarium/presentation/info_aquarium_screen.dart';
import 'package:aquarium_ecosysteem/features/quiz/presentation/quiz_screen.dart';
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
    return switch (screen) {
      AppScreen.ecosystem => const GameHostScreen(),
      AppScreen.info => const InfoAquariumScreen(),
      AppScreen.quiz => const QuizScreen(),
      AppScreen.start => const StartScreen(),
    };
  }
}
