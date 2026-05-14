import 'package:aquarium_ecosysteem/features/quiz/data/quiz_question.dart';
import 'package:flutter/material.dart';

/// Toont de foto bij een quizvraag. Wisselt soepel (fade) van de
/// "fout"-foto naar de echte foto zodra de vraag beantwoord is —
/// goed of fout. Zo zien kinderen altijd hoe het dier of koraal er
/// echt uitziet en leren ze van een verkeerd antwoord.
class QuizImageView extends StatelessWidget {
  const QuizImageView({
    required this.question,
    required this.revealAnswer,
    super.key,
  });

  final QuizQuestion question;

  /// Als `true`, toon de echte foto; anders de bewerkte "fout"-versie.
  final bool revealAnswer;

  @override
  Widget build(BuildContext context) {
    final path = revealAnswer
        ? question.correctImagePath
        : question.wrongImagePath;
    return AspectRatio(
      aspectRatio: question.imageAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: Image.asset(
            path,
            key: ValueKey(path),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}
