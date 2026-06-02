import 'package:aquarium_ecosysteem/app/app_screen.dart';
import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/quiz/data/quiz_catalog.dart';
import 'package:aquarium_ecosysteem/features/quiz/data/quiz_question.dart';
import 'package:aquarium_ecosysteem/features/quiz/presentation/widgets/quiz_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Phase { intro, question, done }

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  _Phase _phase = _Phase.intro;
  int _currentIndex = 0;
  int? _pickedAnswer;

  QuizQuestion get _current => quizCatalog[_currentIndex];

  void _startQuiz() {
    setState(() {
      _phase = _Phase.question;
      _currentIndex = 0;
      _pickedAnswer = null;
    });
  }

  void _pickAnswer(int index) {
    if (_pickedAnswer != null) return; // antwoord al gegeven
    setState(() => _pickedAnswer = index);
  }

  void _next() {
    if (_currentIndex + 1 < quizCatalog.length) {
      setState(() {
        _currentIndex += 1;
        _pickedAnswer = null;
      });
    } else {
      setState(() => _phase = _Phase.done);
    }
  }

  void _back() {
    ref.read(appScreenProvider.notifier).goTo(AppScreen.start);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReefColors.deepSea,
      body: SafeArea(
        child: switch (_phase) {
          _Phase.intro => _IntroView(onStart: _startQuiz, onBack: _back),
          _Phase.question => _QuestionView(
              question: _current,
              questionNumber: _currentIndex + 1,
              totalQuestions: quizCatalog.length,
              pickedAnswer: _pickedAnswer,
              onAnswer: _pickAnswer,
              onNext: _next,
              onBack: _back,
            ),
          _Phase.done => _DoneView(onBack: _back),
        },
      ),
    );
  }
}

// -------------------- Intro --------------------

class _IntroView extends StatelessWidget {
  const _IntroView({required this.onStart, required this.onBack});

  final VoidCallback onStart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final phone = constraints.maxWidth < 480;
        final compact = constraints.maxWidth < 720;
        final titleSize = phone ? 38.0 : (compact ? 56.0 : 76.0);
        final bodySize = phone ? 16.0 : (compact ? 19.0 : 22.0);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: phone ? 18 : 32,
            vertical: phone ? 16 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BackRow(onBack: onBack, label: 'QUIZ'),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Container(
                      padding: EdgeInsets.all(compact ? 24 : 36),
                      decoration: BoxDecoration(
                        color: ReefColors.paper.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: ReefColors.navy, width: 1.6),
                        boxShadow: [
                          BoxShadow(
                            color: ReefColors.navy.withValues(alpha: 0.32),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'KLAAR VOOR DE QUIZ?',
                              textAlign: TextAlign.center,
                              style: ReefTypography.display(
                                size: titleSize,
                                color: ReefColors.navy,
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 14 : 20),
                          Text(
                            'Ben je klaar om het aquarium nog meer te '
                            'ontdekken? Doe de quiz en test wat je hebt '
                            'geleerd over alle dieren en koralen!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: ReefTypography.labelFamily,
                              color: ReefColors.ink,
                              fontSize: bodySize,
                              height: 1.45,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: compact ? 22 : 32),
                          _PrimaryButton(
                            label: 'START QUIZ',
                            color: ReefColors.reefGold,
                            icon: Icons.play_arrow_rounded,
                            onTap: onStart,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// -------------------- Vraag --------------------

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.pickedAnswer,
    required this.onAnswer,
    required this.onNext,
    required this.onBack,
  });

  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? pickedAnswer;
  final ValueChanged<int> onAnswer;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final phone = constraints.maxWidth < 480;
        final compact = constraints.maxWidth < 720;
        final wide = constraints.maxWidth >= 900;

        final answered = pickedAnswer != null;
        final imageView = QuizImageView(
          question: question,
          revealAnswer: answered,
        );
        final panel = _QuestionPanel(
          question: question,
          pickedAnswer: pickedAnswer,
          phone: phone,
          compact: compact,
          onAnswer: onAnswer,
          onNext: onNext,
        );

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: phone ? 14 : 24,
            vertical: phone ? 12 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BackRow(
                onBack: onBack,
                label: 'VRAAG $questionNumber / $totalQuestions',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 5, child: Center(child: imageView)),
                          const SizedBox(width: 24),
                          Expanded(flex: 4, child: panel),
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: phone ? 200 : 260,
                            child: Center(child: imageView),
                          ),
                          const SizedBox(height: 16),
                          Expanded(child: panel),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({
    required this.question,
    required this.pickedAnswer,
    required this.phone,
    required this.compact,
    required this.onAnswer,
    required this.onNext,
  });

  final QuizQuestion question;
  final int? pickedAnswer;
  final bool phone;
  final bool compact;
  final ValueChanged<int> onAnswer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final answered = pickedAnswer != null;
    final isCorrect = answered && pickedAnswer == question.correctIndex;
    final titleSize = phone ? 30.0 : (compact ? 40.0 : 52.0);
    final sciSize = phone ? 13.0 : (compact ? 16.0 : 19.0);
    final questionSize = phone ? 14.0 : (compact ? 18.0 : 21.0);
    final tipSize = phone ? 12.0 : (compact ? 14.0 : 16.0);
    final explanationSize = phone ? 13.0 : (compact ? 16.0 : 18.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 18 : 26,
        vertical: compact ? 18 : 24,
      ),
      decoration: BoxDecoration(
        color: ReefColors.navy,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ReefColors.paper, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Naam + wetenschappelijke naam met witte rand zoals in design.
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 18,
              vertical: compact ? 10 : 14,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: ReefColors.paper, width: 1.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    question.dutchName.toUpperCase(),
                    style: ReefTypography.display(
                      size: titleSize,
                      color: ReefColors.paper,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.scientificName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: ReefTypography.labelFamily,
                    color: ReefColors.paper.withValues(alpha: 0.86),
                    fontSize: sciSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 14 : 20),
          Text(
            question.question.toUpperCase(),
            style: ReefTypography.condensed(
              size: questionSize,
              color: ReefColors.paper,
            ).copyWith(letterSpacing: 0.8),
          ),
          const SizedBox(height: 4),
          Text(
            question.questionTip,
            style: TextStyle(
              fontFamily: ReefTypography.labelFamily,
              color: ReefColors.paper.withValues(alpha: 0.75),
              fontSize: tipSize,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: compact ? 14 : 20),
          if (answered)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                (isCorrect ? question.correctTitle : 'Helaas!').toUpperCase(),
                style: ReefTypography.display(
                  size: phone ? 28.0 : (compact ? 34.0 : 42.0),
                  color: ReefColors.paper,
                ),
              ),
            ),
          // Vóór het antwoord: drie keuzeknoppen. Na het antwoord: óf alleen
          // de groene juiste knop (bij goed) óf jouw rode pick + de groene
          // juiste eronder (bij fout) + altijd de uitleg. Past op een iPad
          // zonder scrollen.
          if (answered) ...[
            if (!isCorrect) ...[
              _AnswerButton(
                label: question.answers[pickedAnswer!],
                state: _AnswerState.wrong,
                onTap: null,
              ),
              const SizedBox(height: 8),
              Text(
                'Het juiste antwoord:',
                style: TextStyle(
                  fontFamily: ReefTypography.labelFamily,
                  color: ReefColors.paper.withValues(alpha: 0.85),
                  fontSize: phone ? 12.0 : (compact ? 14.0 : 16.0),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
            ],
            _AnswerButton(
              label: question.answers[question.correctIndex],
              state: _AnswerState.correct,
              onTap: null,
            ),
            SizedBox(height: compact ? 14 : 18),
            Flexible(
              child: Text(
                question.correctExplanation,
                style: TextStyle(
                  fontFamily: ReefTypography.labelFamily,
                  color: ReefColors.paper,
                  fontSize: explanationSize,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: _PrimaryButton(
                label: 'VOLGENDE',
                color: ReefColors.paper,
                icon: Icons.arrow_forward_rounded,
                onTap: onNext,
              ),
            ),
          ] else
            for (var i = 0; i < question.answers.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _AnswerButton(
                label: question.answers[i],
                state: _AnswerState.neutral,
                onTap: () => onAnswer(i),
              ),
            ],
        ],
      ),
    );
  }
}

enum _AnswerState { neutral, correct, wrong }

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _AnswerState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _AnswerState.correct => const Color(0xFFA8DC68),
      _AnswerState.wrong => const Color(0xFFE17B6E),
      _AnswerState.neutral => ReefColors.paper,
    };
    final disabled = onTap == null;

    return Material(
      color: color,
      elevation: state == _AnswerState.correct ? 6 : 3,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: state == _AnswerState.correct
              ? const Color(0xFF5C8B30)
              : ReefColors.navy.withValues(alpha: 0.6),
          width: 1.6,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: ReefTypography.condensed(
              size: 18,
              color: state == _AnswerState.wrong && disabled
                  ? ReefColors.navy.withValues(alpha: 0.6)
                  : ReefColors.navy,
            ).copyWith(letterSpacing: 1.2),
          ),
        ),
      ),
    );
  }
}

// -------------------- Klaar --------------------

class _DoneView extends StatelessWidget {
  const _DoneView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final phone = constraints.maxWidth < 480;
        final compact = constraints.maxWidth < 720;
        final titleSize = phone ? 38.0 : (compact ? 56.0 : 72.0);
        final bodySize = phone ? 15.0 : (compact ? 18.0 : 21.0);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: phone ? 18 : 32,
            vertical: phone ? 16 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BackRow(onBack: onBack, label: 'KLAAR!'),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Container(
                      padding: EdgeInsets.all(compact ? 24 : 36),
                      decoration: BoxDecoration(
                        color: ReefColors.paper.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: ReefColors.navy, width: 1.6),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'GOED GESPEELD!',
                              style: ReefTypography.display(
                                size: titleSize,
                                color: ReefColors.navy,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Je hebt alle vragen gehad. Wil je nog '
                            'meer ontdekken? Ga terug naar het menu!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: ReefTypography.labelFamily,
                              color: ReefColors.ink,
                              fontSize: bodySize,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: compact ? 22 : 30),
                          _PrimaryButton(
                            label: 'TERUG NAAR MENU',
                            color: ReefColors.reefGold,
                            icon: Icons.home_rounded,
                            onTap: onBack,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// -------------------- Gedeelde widgets --------------------

class _BackRow extends StatelessWidget {
  const _BackRow({required this.onBack, required this.label});

  final VoidCallback onBack;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ReefTypography.condensed(
              size: 22,
              color: ReefColors.paper,
            ).copyWith(letterSpacing: 2),
          ),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: 'Naar startmenu',
          child: IconButton.filled(
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: ReefColors.paper.withValues(alpha: 0.94),
              foregroundColor: ReefColors.navy,
              side: const BorderSide(color: ReefColors.navy, width: 1.4),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.home_rounded),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: ReefColors.navy, width: 1.8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: ReefTypography.condensed(
                  size: 20,
                  color: ReefColors.navy,
                ).copyWith(letterSpacing: 1.4),
              ),
              const SizedBox(width: 10),
              Icon(icon, color: ReefColors.navy, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
