import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:aquarium_ecosysteem/app/app_screen.dart';
import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/application/reef_controller.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/application/tutorial_controller.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_action_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorialOverlay extends ConsumerWidget {
  const TutorialOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final phone = constraints.maxWidth < 480;
        final compact = constraints.maxWidth < 720;
        final cardWidth = phone
            ? constraints.maxWidth - 16
            : compact
                ? constraints.maxWidth - 32
                : math.min(constraints.maxWidth - 80, 720.0);
        final maxCardHeight = constraints.maxHeight - (phone ? 24 : 48);
        final videoHeight = phone ? 170.0 : (compact ? 220.0 : 320.0);
        final cardPadding = phone ? 14.0 : (compact ? 18.0 : 26.0);
        final titleSize = phone ? 22.0 : (compact ? 28.0 : 38.0);
        final subtitleSize = phone ? 12.0 : (compact ? 13.0 : 15.0);

        return Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: ReefColors.navy.withValues(alpha: 0.55),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: cardWidth,
                  maxHeight: maxCardHeight,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: ReefColors.paper.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: ReefColors.navy.withValues(alpha: 0.4),
                          width: 1.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ReefColors.navy.withValues(alpha: 0.32),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'WELKOM OP HET RIF!',
                              textAlign: TextAlign.center,
                              style: ReefTypography.display(
                                size: titleSize,
                                color: ReefColors.navy,
                              ),
                            ),
                            SizedBox(height: phone ? 4 : (compact ? 6 : 10)),
                            Text(
                              'Bekijk eerst de uitleg of start je avontuur.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: ReefTypography.labelFamily,
                                color: ReefColors.ink,
                                fontSize: subtitleSize,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: phone ? 10 : (compact ? 14 : 20)),
                            SizedBox(
                              width: double.infinity,
                              height: videoHeight,
                              child: TutorialAnimation(phone: phone),
                            ),
                            SizedBox(height: phone ? 12 : (compact ? 16 : 22)),
                            _DelayedStartButton(
                              compact: compact,
                              onPressed: () => ref
                                  .read(ecosystemPhaseProvider.notifier)
                                  .play(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top +
                  (phone ? 8.0 : (compact ? 10.0 : 18.0)),
              right: MediaQuery.paddingOf(context).right +
                  (phone ? 8.0 : (compact ? 10.0 : 18.0)),
              child: ReefHomeButton(
                onPressed: () {
                  ref.read(reefControllerProvider.notifier).reset();
                  ref.read(ecosystemPhaseProvider.notifier).restart();
                  ref
                      .read(appScreenProvider.notifier)
                      .goTo(AppScreen.start);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TutorialButton extends StatelessWidget {
  const _TutorialButton({
    required this.label,
    required this.primary,
    required this.compact,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool primary;
  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = primary ? ReefColors.paper : ReefColors.navy;
    final background = primary
        ? ReefColors.navy
        : ReefColors.paper.withValues(alpha: 0.9);
    final borderColor = ReefColors.navy;

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1.6),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 20 : 28,
            vertical: compact ? 12 : 16,
          ),
          child: Text(
            label,
            style: ReefTypography.condensed(
              size: compact ? 14 : 17,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}

/// Toont de START-knop pas na een korte wachttijd, zodat kinderen
/// eerst even naar de uitleg kijken en er niet meteen op drukken.
class _DelayedStartButton extends StatefulWidget {
  const _DelayedStartButton({
    required this.compact,
    required this.onPressed,
  });

  final bool compact;
  final VoidCallback onPressed;

  @override
  State<_DelayedStartButton> createState() => _DelayedStartButtonState();
}

class _DelayedStartButtonState extends State<_DelayedStartButton> {
  static const _delay = Duration(seconds: 10);
  Timer? _timer;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_delay, () {
      if (mounted) {
        setState(() => _ready = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _ready
          ? _TutorialButton(
              key: const ValueKey('start'),
              label: 'START',
              primary: true,
              compact: widget.compact,
              onPressed: widget.onPressed,
            )
          : Padding(
              key: const ValueKey('wait'),
              padding: EdgeInsets.symmetric(
                horizontal: widget.compact ? 20 : 28,
                vertical: widget.compact ? 12 : 16,
              ),
              child: Text(
                'Bekijk eerst de uitleg…',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: ReefTypography.labelFamily,
                  color: ReefColors.ink.withValues(alpha: 0.6),
                  fontSize: widget.compact ? 13 : 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }
}

enum TutorialStage { welcome, algae, fish, crab, goal, success }

class _StageInfo {
  const _StageInfo({
    required this.stage,
    required this.durationMs,
    required this.caption,
  });

  final TutorialStage stage;
  final int durationMs;
  final String caption;
}

const List<_StageInfo> _stages = [
  _StageInfo(
    stage: TutorialStage.welcome,
    durationMs: 6500,
    caption: 'Welkom op je rifavontuur! Speur mee tussen algen, vissen '
        'en krabben.',
  ),
  _StageInfo(
    stage: TutorialStage.algae,
    durationMs: 7500,
    caption: 'Algen maken voedsel en zuurstof. Belangrijk voor het rif!',
  ),
  _StageInfo(
    stage: TutorialStage.fish,
    durationMs: 7500,
    caption: 'Vissen eten algen op en geven mest aan het rif.',
  ),
  _StageInfo(
    stage: TutorialStage.crab,
    durationMs: 7500,
    caption: 'Krabben knippen algen weg en ruimen de bodem op.',
  ),
  _StageInfo(
    stage: TutorialStage.goal,
    durationMs: 9500,
    caption: 'Jouw missie: verstoor het rif en breng het in balans!',
  ),
  _StageInfo(
    stage: TutorialStage.success,
    durationMs: 5000,
    caption: 'Klaar voor je avontuur? Klik op START!',
  ),
];

int get _totalDurationMs =>
    _stages.fold(0, (sum, stage) => sum + stage.durationMs);

class TutorialAnimation extends StatefulWidget {
  const TutorialAnimation({this.phone = false, super.key});

  final bool phone;

  @override
  State<TutorialAnimation> createState() => TutorialAnimationState();
}

class TutorialAnimationState extends State<TutorialAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _phaseController;
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _phaseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalDurationMs),
    )..repeat();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _phaseController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  _StageInfo _currentStage(double timeMs) {
    var acc = 0;
    for (final stage in _stages) {
      acc += stage.durationMs;
      if (timeMs < acc) {
        return stage;
      }
    }
    return _stages.last;
  }

  double _stageProgress(double timeMs, _StageInfo stage) {
    var acc = 0;
    for (final s in _stages) {
      if (identical(s, stage)) {
        break;
      }
      acc += s.durationMs;
    }
    return ((timeMs - acc) / stage.durationMs).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_phaseController, _ambientController]),
      builder: (context, _) {
        final timeMs = _phaseController.value * _totalDurationMs;
        final stage = _currentStage(timeMs);
        final stageProgress = _stageProgress(timeMs, stage);

        const fadeWindow = 0.025;
        final v = _phaseController.value;
        final fadeIn = v < fadeWindow ? v / fadeWindow : 1.0;
        final fadeOut = v > (1 - fadeWindow)
            ? (1 - v) / fadeWindow
            : 1.0;
        final cycleOpacity = math.min(fadeIn, fadeOut).clamp(0.0, 1.0);

        return Opacity(
          opacity: cycleOpacity,
          child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CustomPaint(
                  painter: _TutorialPainter(
                    ambient: _ambientController.value,
                    stage: stage.stage,
                    stageProgress: stageProgress,
                  ),
                ),
              ),
            ),
            if (stage.stage == TutorialStage.goal)
              Positioned.fill(
                child: _GoalFrameOverlay(phone: widget.phone),
              ),
            if (stage.stage == TutorialStage.success)
              Positioned.fill(
                child: _SuccessFrameOverlay(phone: widget.phone),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  widget.phone ? 12 : 20,
                  widget.phone ? 10 : 14,
                  widget.phone ? 12 : 20,
                  widget.phone ? 12 : 18,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      ReefColors.navy.withValues(alpha: 0.75),
                      ReefColors.navy.withValues(alpha: 0.95),
                    ],
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 360),
                  child: Text(
                    stage.caption,
                    key: ValueKey(stage.stage),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: ReefTypography.labelFamily,
                      color: ReefColors.paper,
                      fontSize: widget.phone ? 14 : 20,
                      height: 1.3,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(
                          color: ReefColors.navy,
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: _StageDots(stage: stage.stage),
            ),
          ],
        ),
        );
      },
    );
  }
}

class _GoalFrameOverlay extends StatelessWidget {
  const _GoalFrameOverlay({required this.phone});

  final bool phone;

  @override
  Widget build(BuildContext context) {
    final card1 = _GoalStepCard(
      number: '1',
      title: 'Verstoor',
      subtitle: phone
          ? 'Kies één dier dat het rif verandert.'
          : 'Kies één dier dat\nhet rif verandert.',
      accent: ReefColors.softCoral,
      phone: phone,
    );
    final card2 = _GoalStepCard(
      number: '2',
      title: 'Red het rif',
      subtitle: phone
          ? 'Speur naar het dier dat de balans redt.'
          : 'Speur naar het dier\ndat de balans redt.',
      accent: ReefColors.brightAlgae,
      phone: phone,
    );

    return ColoredBox(
      color: ReefColors.navy.withValues(alpha: 0.42),
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            phone ? 12 : 28,
            phone ? 10 : 18,
            phone ? 12 : 28,
            phone ? 56 : 80,
          ),
          child: phone
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    card1,
                    const SizedBox(height: 6),
                    const Icon(
                      Icons.arrow_downward_rounded,
                      color: ReefColors.paper,
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    card2,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    card1,
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: ReefColors.paper,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    card2,
                  ],
                ),
        ),
      ),
    );
  }
}

class _GoalStepCard extends StatelessWidget {
  const _GoalStepCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.phone = false,
  });

  final String number;
  final String title;
  final String subtitle;
  final Color accent;
  final bool phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: phone ? 220 : 168,
      padding: EdgeInsets.fromLTRB(
        phone ? 12 : 14,
        phone ? 10 : 14,
        phone ? 12 : 14,
        phone ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: ReefColors.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ReefColors.navy, width: 2),
        boxShadow: [
          BoxShadow(
            color: ReefColors.navy.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: phone ? 36 : 44,
            height: phone ? 36 : 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              border: Border.all(color: ReefColors.navy, width: 2),
            ),
            child: Text(
              number,
              style: ReefTypography.display(
                size: phone ? 20 : 26,
                color: ReefColors.navy,
              ),
            ),
          ),
          SizedBox(height: phone ? 6 : 10),
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: ReefTypography.condensed(
              size: phone ? 14 : 16,
              color: ReefColors.navy,
            ),
          ),
          SizedBox(height: phone ? 4 : 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: ReefTypography.labelFamily,
              color: ReefColors.ink,
              fontSize: phone ? 11 : 13,
              height: 1.25,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessFrameOverlay extends StatelessWidget {
  const _SuccessFrameOverlay({required this.phone});

  final bool phone;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ReefColors.navy.withValues(alpha: 0.55),
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            phone ? 12 : 20,
            phone ? 8 : 12,
            phone ? 12 : 20,
            phone ? 56 : 80,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: phone ? 24 : 36,
              vertical: phone ? 18 : 24,
            ),
            decoration: BoxDecoration(
              color: ReefColors.paper,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: ReefColors.navy, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: ReefColors.navy.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SUCCES!',
                  style: ReefTypography.display(
                    size: phone ? 38 : 56,
                    color: ReefColors.navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tijd om het rif te redden.',
                  textAlign: TextAlign.center,
                  style: ReefTypography.condensed(
                    size: phone ? 13 : 16,
                    color: ReefColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StageDots extends StatelessWidget {
  const _StageDots({required this.stage});

  final TutorialStage stage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final s in TutorialStage.values) ...[
          Container(
            width: s == stage ? 22 : 9,
            height: 9,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: s == stage
                  ? ReefColors.paper
                  : ReefColors.paper.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: ReefColors.navy.withValues(alpha: 0.65),
                width: 1,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TutorialPainter extends CustomPainter {
  _TutorialPainter({
    required this.ambient,
    required this.stage,
    required this.stageProgress,
  });

  final double ambient;
  final TutorialStage stage;
  final double stageProgress;

  @override
  void paint(Canvas canvas, Size size) {
    _paintWater(canvas, size);
    _paintLight(canvas, size);
    _paintFloor(canvas, size);
    _paintAlgae(canvas, size);
    _paintFish(canvas, size);
    _paintCrabs(canvas, size);
    _paintBubbles(canvas, size);

    switch (stage) {
      case TutorialStage.welcome:
      case TutorialStage.goal:
      case TutorialStage.success:
        break;
      case TutorialStage.algae:
        _paintAlgaeSpotlight(canvas, size);
        break;
      case TutorialStage.fish:
        _paintFishAction(canvas, size);
        break;
      case TutorialStage.crab:
        _paintCrabAction(canvas, size);
        break;
    }
  }

  void _paintWater(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F4A73),
            Color(0xFF287C8E),
            Color(0xFF415378),
            Color(0xFF4A253A),
          ],
        ).createShader(rect),
    );

    final glow = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          0.5 + math.sin(ambient * math.pi * 2) * 0.1,
          -0.4,
        ),
        radius: 0.8,
        colors: [
          ReefColors.reefGold.withValues(alpha: 0.42),
          ReefColors.water.withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, glow);
  }

  void _paintLight(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    final sway = math.sin(ambient * math.pi * 2) * size.width * 0.03;
    for (var i = 0; i < 4; i++) {
      final start = size.width * (0.1 + i * 0.22) + sway;
      final path = Path()
        ..moveTo(start, 0)
        ..lineTo(start + size.width * 0.09, 0)
        ..lineTo(start + size.width * (0.18 + i * 0.02), size.height)
        ..lineTo(start - size.width * 0.1, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _paintFloor(Canvas canvas, Size size) {
    final floorPaint = Paint()..color = const Color(0xFF372137);
    final floor = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.7,
        size.width * 0.55,
        size.height * 0.88,
        size.width * 0.78,
        size.height * 0.78,
      )
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.72,
        size.width * 0.95,
        size.height * 0.82,
        size.width,
        size.height * 0.74,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(floor, floorPaint);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.93),
        width: size.width * 0.82,
        height: size.height * 0.18,
      ),
      Paint()..color = ReefColors.sand.withValues(alpha: 0.5),
    );

    final coralColors = [
      ReefColors.coral,
      ReefColors.reefGold,
      ReefColors.purple,
      ReefColors.brightAlgae,
      ReefColors.softCoral,
    ];
    for (var i = 0; i < 12; i++) {
      final x = size.width * ((0.06 + i * 0.082) % 0.94);
      final y = size.height * (0.79 + (i % 4) * 0.03);
      final scale = size.shortestSide * 0.04;
      final color = coralColors[i % coralColors.length];
      final paint = Paint()
        ..color = color.withValues(alpha: 0.9)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = scale * 0.2;
      final sway = math.sin(ambient * math.pi * 2 + i) * scale * 0.12;
      final base = Offset(x, y);
      canvas.drawLine(base, base.translate(sway, -scale * 1.5), paint);
      canvas.drawLine(
        base.translate(sway * 0.3, -scale * 0.6),
        base.translate(-scale * 0.8, -scale * 1.1),
        paint,
      );
      canvas.drawLine(
        base.translate(sway * 0.3, -scale * 0.9),
        base.translate(scale * 0.7, -scale * 1.3),
        paint,
      );
      canvas.drawCircle(base.translate(sway, -scale * 1.55), scale * 0.18, paint);
    }
  }

  void _paintAlgae(Canvas canvas, Size size) {
    for (var i = 0; i < 14; i++) {
      final x = size.width * ((0.05 + i * 0.067) % 0.95);
      final base = Offset(x, size.height * (0.79 + (i % 4) * 0.025));
      final maxHeight = size.height * (0.085 + (i % 5) * 0.012);
      final wiggle =
          math.sin(ambient * math.pi * 4 + i) * size.width * 0.012;
      final paint = Paint()
        ..color = Color.lerp(
          ReefColors.algae,
          ReefColors.brightAlgae,
          (i % 4) / 4,
        )!.withValues(alpha: 0.82)
        ..strokeWidth = size.shortestSide * 0.008
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(base.dx, base.dy)
        ..cubicTo(
          base.dx - 10,
          base.dy - maxHeight * 0.32,
          base.dx + wiggle,
          base.dy - maxHeight * 0.7,
          base.dx + wiggle * 0.6,
          base.dy - maxHeight,
        );
      canvas.drawPath(path, paint);
    }
  }

  void _paintFish(Canvas canvas, Size size) {
    const colors = [
      ReefColors.reefGold,
      ReefColors.softCoral,
      Color(0xFF82D4E3),
      Color(0xFFFFC658),
    ];
    for (var i = 0; i < 4; i++) {
      final facingRight = i.isOdd;
      final swim = (ambient * (0.22 + i * 0.02) + i * 0.13) % 1.18;
      final x = facingRight
          ? size.width * (swim - 0.09)
          : size.width * (1.09 - swim);
      final y = size.height * (0.24 + (i % 3) * 0.1) +
          math.sin(ambient * math.pi * 2 + i) * size.height * 0.018;
      final fishSize = size.shortestSide * (0.03 + (i % 3) * 0.005);
      _drawFish(
        canvas,
        Offset(x, y),
        fishSize,
        facingRight: facingRight,
        body: colors[i % colors.length],
        accent: colors[(i + 2) % colors.length],
      );
    }
  }

  void _paintCrabs(Canvas canvas, Size size) {
    for (var i = 0; i < 2; i++) {
      final walk =
          math.sin(ambient * math.pi * 2 + i) * size.width * 0.018;
      final x = size.width * (0.22 + i * 0.36) + walk;
      final y = size.height * 0.88;
      _drawCrab(canvas, Offset(x, y), size.shortestSide * 0.03, i);
    }
  }

  void _paintBubbles(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.34);
    for (var i = 0; i < 12; i++) {
      final seed = (i * 0.071) % 1;
      final x = size.width *
          ((0.08 + i * 0.083 +
                  math.sin(ambient * 6 + i) * 0.01) %
              0.94);
      final rise = (ambient * (0.35 + (i % 4) * 0.05) + seed) % 1;
      final y = size.height * (0.96 - rise * 0.92);
      final radius = size.shortestSide * (0.005 + (i % 3) * 0.003);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _paintAlgaeSpotlight(Canvas canvas, Size size) {
    final pulse =
        (math.sin(stageProgress * math.pi * 2) * 0.5 + 0.5).toDouble();
    final glowAlpha = (0.18 + pulse * 0.18).clamp(0.0, 1.0);

    final rect = Rect.fromLTWH(
      size.width * 0.05,
      size.height * 0.55,
      size.width * 0.9,
      size.height * 0.42,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.7,
          colors: [
            ReefColors.brightAlgae.withValues(alpha: glowAlpha),
            Colors.transparent,
          ],
        ).createShader(rect),
    );

    for (var i = 0; i < 18; i++) {
      final lifetime = (stageProgress + i * 0.055) % 1.0;
      final x = size.width * ((0.08 + i * 0.052) % 0.92);
      final y = size.height * (0.88 - lifetime * 0.72);
      final radius =
          size.shortestSide * (0.006 + (i % 3) * 0.003);
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = ReefColors.brightAlgae.withValues(
            alpha: (1 - lifetime) * 0.7,
          ),
      );
    }

    for (var i = 0; i < 6; i++) {
      final x = size.width * (0.15 + i * 0.13);
      final base = Offset(x, size.height * 0.85);
      final maxHeight = size.height * 0.18;
      final grow = Curves.easeOutCubic.transform(
        ((stageProgress - i * 0.03) / 0.4).clamp(0.0, 1.0),
      );
      final height = maxHeight * grow;
      if (height <= 0) {
        continue;
      }
      final wiggle = math.sin(ambient * math.pi * 4 + i) * 8;
      final paint = Paint()
        ..color = ReefColors.brightAlgae.withValues(alpha: 0.95)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(base.dx, base.dy)
        ..cubicTo(
          base.dx - 10,
          base.dy - height * 0.32,
          base.dx + wiggle,
          base.dy - height * 0.7,
          base.dx + wiggle * 0.6,
          base.dy - height,
        );
      canvas.drawPath(path, paint);
    }
  }

  void _paintFishAction(Canvas canvas, Size size) {
    final floorY = size.height * 0.82;
    final targets = [
      Offset(size.width * 0.22, floorY),
      Offset(size.width * 0.5, floorY + size.height * 0.02),
      Offset(size.width * 0.78, floorY),
    ];
    final colors = [
      ReefColors.reefGold,
      ReefColors.softCoral,
      const Color(0xFF82D4E3),
    ];

    for (var i = 0; i < targets.length; i++) {
      final target = targets[i];
      final delay = i * 0.08;
      final localProgress =
          ((stageProgress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (localProgress <= 0) {
        continue;
      }

      final maxAlgae = size.height * 0.16;
      final consume = ((localProgress - 0.30) / 0.20).clamp(0.0, 1.0);
      final algaeRemaining = 1 - consume;
      if (algaeRemaining > 0.02) {
        _drawSingleAlga(canvas, target, maxAlgae * algaeRemaining, 0.95);
      }

      final fromLeft = i.isEven;
      final start = Offset(
        fromLeft ? -size.width * 0.05 : size.width * 1.05,
        size.height * (0.3 + (i % 2) * 0.1),
      );
      final eatPos = target.translate(0, -size.height * 0.05);
      final exitX = fromLeft ? size.width * 1.1 : -size.width * 0.1;
      final exitPos = Offset(exitX, size.height * (0.2 + (i % 2) * 0.08));

      Offset fishPos;
      bool eating = false;
      bool facingRight;
      if (localProgress < 0.3) {
        final phase = localProgress / 0.3;
        final eased = Curves.easeInOutCubic.transform(phase);
        fishPos = Offset.lerp(start, eatPos, eased)!;
        facingRight = start.dx < eatPos.dx;
      } else if (localProgress < 0.55) {
        eating = true;
        final wiggle =
            math.sin(ambient * math.pi * 20 + i) * size.width * 0.005;
        fishPos = eatPos.translate(wiggle, 0);
        facingRight = start.dx < eatPos.dx;
      } else {
        final phase = (localProgress - 0.55) / 0.45;
        final eased = Curves.easeInCubic.transform(phase);
        fishPos = Offset.lerp(eatPos, exitPos, eased)!;
        facingRight = eatPos.dx < exitPos.dx;
      }

      final fishSize = size.shortestSide * 0.052;
      _drawFish(
        canvas,
        fishPos,
        fishSize,
        facingRight: facingRight,
        body: colors[i % colors.length],
        accent: colors[(i + 1) % colors.length],
      );

      if (eating) {
        final mouthSign = facingRight ? 1 : -1;
        final mouthCenter = Offset(
          fishPos.dx + mouthSign * fishSize * 1.0,
          fishPos.dy,
        );
        canvas.drawCircle(
          mouthCenter,
          fishSize * 0.3,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4
            ..color = ReefColors.brightAlgae.withValues(alpha: 0.7),
        );
        for (var p = 0; p < 4; p++) {
          final age = ((ambient * 5 + p * 0.25 + i * 0.13) % 1).toDouble();
          final px = mouthCenter.dx - mouthSign * age * size.width * 0.04;
          final py =
              mouthCenter.dy + math.sin(ambient * 30 + p) * 6;
          canvas.drawCircle(
            Offset(px, py),
            5 * (1 - age),
            Paint()
              ..color =
                  ReefColors.brightAlgae.withValues(alpha: (0.9 - age)),
          );
        }
      }
    }
  }

  void _paintCrabAction(Canvas canvas, Size size) {
    final floorY = size.height * 0.86;
    final scenes = [
      _CrabScene(crabX: 0.28, algaeX: 0.36, side: 1.0),
      _CrabScene(crabX: 0.78, algaeX: 0.66, side: -1.0),
    ];
    const snipsTotal = 4;

    for (var i = 0; i < scenes.length; i++) {
      final scene = scenes[i];
      final restX = scene.crabX * size.width;
      final algaeX = scene.algaeX * size.width;
      final side = scene.side;

      final delay = i * 0.08;
      final localProgress =
          ((stageProgress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (localProgress <= 0) {
        continue;
      }

      final appear = (localProgress / 0.12).clamp(0.0, 1.0);
      final crabScale = Curves.easeOutBack.transform(appear);
      final crabSize = size.shortestSide * 0.06 * crabScale;

      final cutting =
          ((localProgress - 0.12) / 0.78).clamp(0.0, 1.0);
      final cumulative = cutting * snipsTotal;
      final snipsDone = cumulative.floor();
      final snipFrac = cumulative - snipsDone;
      final clawClosure = (1 - 2 * (snipFrac - 0.5).abs()).clamp(0.0, 1.0);

      final algaeRemaining =
          (1 - snipsDone / snipsTotal).clamp(0.0, 1.0);
      final maxHeight = size.height * 0.16;
      final algaeHeight = maxHeight * algaeRemaining;

      if (algaeRemaining > 0.02) {
        _drawSingleAlga(
          canvas,
          Offset(algaeX, floorY),
          algaeHeight,
          0.95,
        );
      }

      if (snipsDone > 0 && snipFrac < 0.7 && cutting < 1.0) {
        final pieceProgress = (snipFrac / 0.7).clamp(0.0, 1.0);
        final pieceY = floorY - algaeHeight - 16 - pieceProgress * 32;
        final pieceX = algaeX + side * pieceProgress * 26;
        _drawAlgaeFragment(
          canvas,
          Offset(pieceX, pieceY),
          18,
          (1 - pieceProgress) * 0.9,
          (pieceProgress - 0.5) * 0.9 * side,
        );
      }

      final snipPosX = algaeX - side * (crabSize * 1.6);
      final currentCrabX = restX + (snipPosX - restX) * clawClosure;
      final crabPos = Offset(currentCrabX, floorY);

      if (clawClosure > 0.55 && algaeHeight > 0) {
        final flash = (clawClosure - 0.55) / 0.45;
        canvas.drawLine(
          Offset(algaeX - 14, floorY - algaeHeight - 2),
          Offset(algaeX + 14, floorY - algaeHeight + 4),
          Paint()
            ..color = Colors.white.withValues(alpha: flash * 0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6
            ..strokeCap = StrokeCap.round,
        );
      }

      _drawCrab(canvas, crabPos, crabSize, i + 100);

      final armStart = Offset(
        crabPos.dx + side * crabSize * 0.55,
        crabPos.dy - crabSize * 0.6,
      );
      final clawCenter = Offset(
        algaeX - side * (crabSize * 0.4 + clawClosure * crabSize * 0.1),
        floorY - algaeHeight - 4,
      );
      final armElbow = Offset(
        (armStart.dx + clawCenter.dx) / 2 + side * crabSize * 0.25,
        (armStart.dy + clawCenter.dy) / 2 - crabSize * 0.35,
      );
      final armPath = Path()
        ..moveTo(armStart.dx, armStart.dy)
        ..quadraticBezierTo(
          armElbow.dx,
          armElbow.dy,
          clawCenter.dx,
          clawCenter.dy,
        );
      canvas.drawPath(
        armPath,
        Paint()
          ..color = const Color(0xFF8E2D35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = crabSize * 0.32
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        armPath,
        Paint()
          ..color = ReefColors.coral
          ..style = PaintingStyle.stroke
          ..strokeWidth = crabSize * 0.24
          ..strokeCap = StrokeCap.round,
      );

      _drawScissorClaw(
        canvas,
        clawCenter,
        crabSize * 1.0,
        side,
        1 - clawClosure,
      );
    }
  }

  void _drawSingleAlga(
    Canvas canvas,
    Offset base,
    double height,
    double alpha,
  ) {
    if (height <= 0 || alpha <= 0) {
      return;
    }
    final wiggle = math.sin(ambient * math.pi * 4 + base.dx) * 6;
    final paint = Paint()
      ..color = ReefColors.brightAlgae.withValues(
        alpha: alpha.clamp(0.0, 1.0),
      )
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..cubicTo(
        base.dx - 10,
        base.dy - height * 0.32,
        base.dx + wiggle,
        base.dy - height * 0.7,
        base.dx + wiggle * 0.6,
        base.dy - height,
      );
    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(base.dx + wiggle * 0.6, base.dy - height),
      4,
      Paint()
        ..color = ReefColors.brightAlgae.withValues(
          alpha: alpha.clamp(0.0, 1.0),
        ),
    );
  }

  void _drawAlgaeFragment(
    Canvas canvas,
    Offset center,
    double size,
    double alpha,
    double angle,
  ) {
    if (alpha <= 0) {
      return;
    }
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final paint = Paint()
      ..color = ReefColors.brightAlgae.withValues(
        alpha: alpha.clamp(0.0, 1.0),
      )
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-size / 2, size / 4),
      Offset(size / 2, -size / 4),
      paint,
    );
    canvas.restore();
  }

  void _drawScissorClaw(
    Canvas canvas,
    Offset center,
    double size,
    double side,
    double openness,
  ) {
    final fill = Paint()..color = ReefColors.coral;
    final outline = Paint()
      ..color = const Color(0xFF8E2D35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(side, 1);
    final spread = openness * size * 0.45;
    final upper = Path()
      ..moveTo(0, -spread * 0.18)
      ..quadraticBezierTo(
        size * 0.4,
        -spread - size * 0.18,
        size * 0.95,
        -spread * 0.55,
      )
      ..quadraticBezierTo(size * 0.6, -spread * 0.05, 0, 0)
      ..close();
    canvas.drawPath(upper, fill);
    canvas.drawPath(upper, outline);
    final lower = Path()
      ..moveTo(0, spread * 0.18)
      ..quadraticBezierTo(
        size * 0.4,
        spread + size * 0.18,
        size * 0.95,
        spread * 0.55,
      )
      ..quadraticBezierTo(size * 0.6, spread * 0.05, 0, 0)
      ..close();
    canvas.drawPath(lower, fill);
    canvas.drawPath(lower, outline);
    canvas.restore();
  }

  void _drawFish(
    Canvas canvas,
    Offset center,
    double size, {
    required bool facingRight,
    required Color body,
    required Color accent,
  }) {
    final bodyPaint = Paint()..color = body;
    final accentPaint = Paint()..color = accent.withValues(alpha: 0.92);
    final inkPaint = Paint()..color = ReefColors.ink.withValues(alpha: 0.86);
    final finPaint = Paint()..color = Colors.white.withValues(alpha: 0.34);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(facingRight ? 1 : -1, 1);
    final tail = Path()
      ..moveTo(-size * 1.04, 0)
      ..lineTo(-size * 1.82, -size * 0.62)
      ..lineTo(-size * 1.78, size * 0.62)
      ..close();
    canvas.drawPath(tail, accentPaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size * 2.35,
        height: size * 1.18,
      ),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size * 0.05, size * 0.44),
        width: size * 0.72,
        height: size * 0.32,
      ),
      finPaint,
    );
    canvas.drawCircle(Offset(size * 0.62, -size * 0.16), size * 0.12, inkPaint);
    canvas.drawCircle(
      Offset(size * 0.66, -size * 0.18),
      size * 0.04,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size * 0.78, size * 0.14),
        width: size * 0.45,
        height: size * 0.26,
      ),
      0,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.06
        ..color = ReefColors.ink.withValues(alpha: 0.42),
    );
    canvas.restore();
  }

  void _drawCrab(Canvas canvas, Offset center, double size, int index) {
    final bodyPaint = Paint()..color = ReefColors.coral;
    final accentPaint = Paint()..color = ReefColors.softCoral;
    final linePaint = Paint()
      ..color = const Color(0xFF8E2D35)
      ..strokeWidth = size * 0.13
      ..strokeCap = StrokeCap.round;
    final eyePaint = Paint()..color = ReefColors.paper;
    final pupilPaint = Paint()..color = ReefColors.ink.withValues(alpha: 0.78);
    final step = math.sin(ambient * math.pi * 8 + index) * size * 0.12;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 2.05, height: size * 1.2),
      bodyPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: center.translate(0, -size * 0.08),
        width: size * 1.18,
        height: size * 0.64,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = accentPaint.color.withValues(alpha: 0.76)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.16
        ..strokeCap = StrokeCap.round,
    );
    for (final direction in [-1.0, 1.0]) {
      canvas.drawLine(
        center.translate(direction * size * 0.72, -size * 0.18),
        center.translate(direction * size * 1.54, -size * 0.88 + step),
        linePaint,
      );
      for (var leg = 0; leg < 4; leg++) {
        final legY = size * (-0.18 + leg * 0.22);
        final knee = center.translate(
          direction * size * (0.58 + leg * 0.08),
          legY + step * (leg.isEven ? 1 : -0.6),
        );
        final foot = center.translate(
          direction * size * (1.08 + leg * 0.2),
          size * (0.2 + leg * 0.18) - step,
        );
        canvas.drawLine(
          center.translate(direction * size * 0.34, legY),
          knee,
          linePaint,
        );
        canvas.drawLine(knee, foot, linePaint);
      }
    }
    canvas.drawLine(
      center.translate(-size * 0.34, -size * 0.4),
      center.translate(-size * 0.46, -size * 0.82),
      linePaint,
    );
    canvas.drawLine(
      center.translate(size * 0.34, -size * 0.4),
      center.translate(size * 0.46, -size * 0.82),
      linePaint,
    );
    canvas.drawCircle(
      center.translate(-size * 0.48, -size * 0.9),
      size * 0.17,
      eyePaint,
    );
    canvas.drawCircle(
      center.translate(size * 0.48, -size * 0.9),
      size * 0.17,
      eyePaint,
    );
    canvas.drawCircle(
      center.translate(-size * 0.43, -size * 0.9),
      size * 0.06,
      pupilPaint,
    );
    canvas.drawCircle(
      center.translate(size * 0.53, -size * 0.9),
      size * 0.06,
      pupilPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TutorialPainter oldDelegate) {
    return oldDelegate.ambient != ambient ||
        oldDelegate.stage != stage ||
        oldDelegate.stageProgress != stageProgress;
  }
}

class _CrabScene {
  const _CrabScene({
    required this.crabX,
    required this.algaeX,
    required this.side,
  });

  final double crabX;
  final double algaeX;
  final double side;
}
