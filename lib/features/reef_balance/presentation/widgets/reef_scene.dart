import 'dart:math' as math;

import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_action.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:flutter/material.dart';

class ReefScene extends StatefulWidget {
  const ReefScene({required this.reef, super.key});

  final ReefState reef;

  @override
  State<ReefScene> createState() => _ReefSceneState();
}

class _ReefSceneState extends State<ReefScene> with TickerProviderStateMixin {
  late final AnimationController _swimController;
  late final AnimationController _burstController;
  late Listenable _repaint;

  @override
  void initState() {
    super.initState();
    _swimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );
    _repaint = Listenable.merge([_swimController, _burstController]);
  }

  @override
  void didUpdateWidget(covariant ReefScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reef.eventId != widget.reef.eventId) {
      _burstController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _swimController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _repaint,
      builder: (context, _) {
        return CustomPaint(
          painter: _ReefScenePainter(
            reef: widget.reef,
            time: _swimController.value,
            burst: _burstController.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ReefScenePainter extends CustomPainter {
  const _ReefScenePainter({
    required this.reef,
    required this.time,
    required this.burst,
  });

  final ReefState reef;
  final double time;
  final double burst;

  @override
  void paint(Canvas canvas, Size size) {
    _paintWater(canvas, size);
    _paintLight(canvas, size);
    _paintFarReef(canvas, size);
    _paintAlgae(canvas, size, backLayer: true);
    _paintFish(canvas, size);
    _paintReefFloor(canvas, size);
    _paintAlgae(canvas, size, backLayer: false);
    _paintCrabs(canvas, size);
    _paintBubbles(canvas, size);
    _paintMoodHaze(canvas, size);
    _paintRipple(canvas, size);
    _paintActionCreatureBurst(canvas, size);
  }

  void _paintWater(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final algaeTint = (reef.algae - 50).clamp(0, 50) / 50;
    final lowFoodTint = (35 - reef.algae).clamp(0, 35) / 35;
    final middle = Color.lerp(
      ReefColors.lagoon,
      ReefColors.algae,
      algaeTint * 0.42,
    )!;
    final bottom = Color.lerp(
      const Color(0xFF415378),
      const Color(0xFF667075),
      lowFoodTint * 0.42,
    )!;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0F4A73),
          middle,
          bottom,
          const Color(0xFF4A253A),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.58 + math.sin(time * math.pi * 2) * 0.08, -0.5),
        radius: 0.78,
        colors: [
          ReefColors.reefGold.withValues(alpha: 0.48),
          ReefColors.water.withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, glowPaint);
  }

  void _paintLight(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final sway = math.sin(time * math.pi * 2) * size.width * 0.035;

    for (var index = 0; index < 5; index++) {
      final start = size.width * (0.08 + index * 0.2) + sway;
      final path = Path()
        ..moveTo(start, 0)
        ..lineTo(start + size.width * 0.1, 0)
        ..lineTo(start + size.width * (0.2 + index * 0.02), size.height)
        ..lineTo(start - size.width * 0.12, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _paintFarReef(Canvas canvas, Size size) {
    final paint = Paint()..color = ReefColors.deepSea.withValues(alpha: 0.24);

    for (var index = 0; index < 9; index++) {
      final x = size.width * (0.05 + index * 0.12);
      final y = size.height * (0.66 + math.sin(index * 1.7) * 0.04);
      final radius = size.shortestSide * (0.045 + (index % 4) * 0.008);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: radius * 2.6,
          height: radius * 1.15,
        ),
        paint,
      );
    }
  }

  void _paintReefFloor(Canvas canvas, Size size) {
    final floorPaint = Paint()..color = const Color(0xFF372137);
    final floor = Path()
      ..moveTo(0, size.height * 0.8)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.71,
        size.width * 0.45,
        size.height * 0.89,
        size.width * 0.68,
        size.height * 0.8,
      )
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.74,
        size.width * 0.92,
        size.height * 0.83,
        size.width,
        size.height * 0.76,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(floor, floorPaint);

    final sandPaint = Paint()..color = ReefColors.sand.withValues(alpha: 0.52);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.48, size.height * 0.91),
        width: size.width * 0.78,
        height: size.height * 0.16,
      ),
      sandPaint,
    );

    final coralHealth = reef.healthScore / 100;
    final coralColors = [
      Color.lerp(const Color(0xFF8D6874), ReefColors.coral, coralHealth)!,
      Color.lerp(const Color(0xFF9A8F75), ReefColors.reefGold, coralHealth)!,
      Color.lerp(const Color(0xFF716F93), ReefColors.purple, coralHealth)!,
      Color.lerp(const Color(0xFF879074), ReefColors.brightAlgae, coralHealth)!,
      Color.lerp(const Color(0xFF946E6A), ReefColors.softCoral, coralHealth)!,
    ];

    for (var index = 0; index < 18; index++) {
      final x = size.width * ((0.04 + index * 0.061) % 0.96);
      final y = size.height * (0.78 + (index % 5) * 0.034);
      final scale = size.shortestSide * (0.038 + (index % 4) * 0.006);
      _drawCoral(canvas, Offset(x, y), scale, coralColors[index % 5], index);
    }
  }

  void _paintAlgae(Canvas canvas, Size size, {required bool backLayer}) {
    final count = reef.algaePatchCount;
    final start = backLayer ? 0 : count ~/ 2;
    final end = backLayer ? count ~/ 2 : count;
    final alpha = backLayer ? 0.48 : 0.86;
    final strokeBase = size.shortestSide * (backLayer ? 0.006 : 0.008);

    for (var index = start; index < end; index++) {
      final seed = index * 1.618;
      final x = size.width * ((0.035 + index * 0.047) % 0.95);
      final baseY = size.height * (0.79 + (index % 7) * 0.027);
      final height = size.height * (0.075 + (reef.algae / 100) * 0.1);
      final wiggle = math.sin(time * math.pi * 2.4 + seed) * size.width * 0.014;
      final paint = Paint()
        ..color = Color.lerp(
          ReefColors.algae,
          ReefColors.brightAlgae,
          (index % 5) / 5,
        )!.withValues(alpha: alpha)
        ..strokeWidth = strokeBase * (1 + (index % 3) * 0.35)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(x, baseY);
      path.cubicTo(
        x - size.width * 0.035,
        baseY - height * 0.28,
        x + wiggle,
        baseY - height * 0.62,
        x + wiggle * 0.8,
        baseY - height,
      );
      canvas.drawPath(path, paint);

      if (!backLayer && index % 3 == 0) {
        canvas.drawCircle(
          Offset(x + wiggle * 0.8, baseY - height),
          size.shortestSide * 0.008,
          Paint()..color = ReefColors.brightAlgae.withValues(alpha: 0.7),
        );
      }
    }

    if (reef.algae > 72 && !backLayer) {
      final cloudPaint = Paint()
        ..color = ReefColors.brightAlgae.withValues(
          alpha: ((reef.algae - 72) / 80).clamp(0.08, 0.24).toDouble(),
        );
      for (var index = 0; index < 18; index++) {
        final x = size.width * ((0.09 + index * 0.083) % 0.9);
        final y = size.height * (0.2 + ((index * 0.137 + time * 0.08) % 0.52));
        canvas.drawCircle(
          Offset(x, y),
          size.shortestSide * (0.008 + (index % 3) * 0.004),
          cloudPaint,
        );
      }
    }
  }

  void _paintFish(Canvas canvas, Size size) {
    final colors = [
      ReefColors.reefGold,
      ReefColors.softCoral,
      const Color(0xFF82D4E3),
      const Color(0xFFFFC658),
      const Color(0xFFB9D86B),
    ];

    final happy = _fishHappy;
    for (var index = 0; index < reef.fishCount; index++) {
      final seed = (index * 0.137) % 1;
      final speed = 0.18 + (index % 5) * 0.018;
      final facingRight = index.isOdd;
      final swim = (time * speed + seed) % 1.18;
      final x = facingRight
          ? size.width * (swim - 0.09)
          : size.width * (1.09 - swim);
      final y =
          size.height * (0.24 + (index % 6) * 0.068) +
          math.sin(time * math.pi * 2 + index) * size.height * 0.018;
      final fishSize = size.shortestSide * (0.026 + (index % 4) * 0.004);

      _drawFish(
        canvas,
        Offset(x, y),
        fishSize,
        facingRight: facingRight,
        body: colors[index % colors.length],
        accent: colors[(index + 2) % colors.length],
        happy: happy,
      );
    }
  }

  bool get _fishHappy => switch (reef.mood) {
    ReefMood.thriving => true,
    ReefMood.balanced => true,
    ReefMood.algaeBloom => false,
    ReefMood.hungry => false,
    ReefMood.overCleaned => false,
    ReefMood.crowded => false,
  };

  void _paintCrabs(Canvas canvas, Size size) {
    for (var index = 0; index < reef.crabCount; index++) {
      final lane = index % 4;
      final walk = math.sin(time * math.pi * 2 + index) * size.width * 0.018;
      final x = size.width * (0.13 + index * 0.105) + walk;
      final y = size.height * (0.86 + lane * 0.024);
      _drawCrab(canvas, Offset(x, y), size.shortestSide * 0.032, index);
    }
  }

  void _paintBubbles(Canvas canvas, Size size) {
    final count = 16 + reef.fishCount;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, size.shortestSide * 0.002)
      ..color = Colors.white.withValues(alpha: 0.36);

    for (var index = 0; index < count; index++) {
      final seed = (index * 0.071) % 1;
      final x =
          size.width *
          ((0.06 + index * 0.113 + math.sin(time * 6 + index) * 0.01) % 0.94);
      final rise = (time * (0.35 + (index % 4) * 0.04) + seed) % 1;
      final y = size.height * (0.96 - rise * 0.92);
      final radius = size.shortestSide * (0.005 + (index % 4) * 0.003);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _paintMoodHaze(Canvas canvas, Size size) {
    Color? color;
    double alpha = 0;

    switch (reef.mood) {
      case ReefMood.algaeBloom:
        color = ReefColors.algae;
        alpha = 0.2;
        break;
      case ReefMood.hungry:
      case ReefMood.overCleaned:
        color = Colors.white;
        alpha = 0.13;
        break;
      case ReefMood.crowded:
        color = ReefColors.coral;
        alpha = 0.09;
        break;
      case ReefMood.thriving:
        color = ReefColors.reefGold;
        alpha = 0.07;
        break;
      case ReefMood.balanced:
        color = null;
        break;
    }

    if (color == null) {
      return;
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = color.withValues(alpha: alpha),
    );
  }

  void _paintRipple(Canvas canvas, Size size) {
    const rippleSpan = 0.32;
    if (burst <= 0 || burst >= rippleSpan) {
      return;
    }

    final progress = burst / rippleSpan;
    final eased = Curves.easeOutCubic.transform(progress);
    final fade = (1 - progress).clamp(0, 1).toDouble();
    final center = Offset(
      reef.rippleX * size.width,
      reef.rippleY * size.height,
    );
    final color = switch (reef.lastAction) {
      ReefAction.algae => ReefColors.brightAlgae,
      ReefAction.fish => ReefColors.reefGold,
      ReefAction.crab => ReefColors.softCoral,
      null => Colors.white,
    };

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.006
      ..color = color.withValues(alpha: fade * 0.58);

    for (var index = 0; index < 3; index++) {
      canvas.drawCircle(
        center,
        size.shortestSide * (0.05 + eased * (0.18 + index * 0.075)),
        ringPaint..color = color.withValues(alpha: fade * (0.5 - index * 0.1)),
      );
    }

    final sparklePaint = Paint()..color = color.withValues(alpha: fade * 0.82);
    for (var index = 0; index < 14; index++) {
      final angle = index / 14 * math.pi * 2;
      final distance = size.shortestSide * (0.03 + eased * 0.24);
      final particle =
          center +
          Offset(math.cos(angle) * distance, math.sin(angle) * distance * 0.72);
      canvas.drawCircle(
        particle,
        size.shortestSide * (0.004 + (index % 3) * 0.002),
        sparklePaint,
      );
    }
  }

  void _paintActionCreatureBurst(Canvas canvas, Size size) {
    final action = reef.lastAction;
    if (action == null || burst <= 0 || burst >= 1) {
      return;
    }

    switch (action) {
      case ReefAction.algae:
        _paintAlgaeBurst(canvas, size);
        break;
      case ReefAction.fish:
        _paintFishBurst(canvas, size);
        break;
      case ReefAction.crab:
        _paintCrabBurst(canvas, size);
        break;
    }
  }

  void _paintAlgaeBurst(Canvas canvas, Size size) {
    final fadeIn = (burst / 0.18).clamp(0.0, 1.0);
    final fadeOut = ((1 - burst) / 0.18).clamp(0.0, 1.0);
    final visibility = fadeIn * fadeOut;
    final grow = Curves.easeOutCubic.transform(burst.clamp(0.0, 1.0));

    final tintPaint = Paint()
      ..color = ReefColors.algae.withValues(
        alpha: 0.22 * visibility,
      );
    canvas.drawRect(Offset.zero & size, tintPaint);

    final stalkCount = 18;
    for (var index = 0; index < stalkCount; index++) {
      final seed = index * 1.31;
      final x = size.width * ((0.04 + index * 0.054) % 0.96);
      final base = Offset(x, size.height * (0.81 + (index % 4) * 0.022));
      final maxHeight = size.height * (0.09 + (index % 5) * 0.018);
      final delay = (index * 0.012).clamp(0.0, 0.2);
      final localProgress = ((burst - delay) / (1 - delay)).clamp(0.0, 1.0);
      final stalkGrow = Curves.easeOutCubic.transform(localProgress);
      final height = maxHeight * stalkGrow;
      if (height <= 0) {
        continue;
      }
      final wiggle =
          math.sin(time * math.pi * 4 + seed) * size.width * 0.013;
      final paint = Paint()
        ..color = Color.lerp(
          ReefColors.algae,
          ReefColors.brightAlgae,
          (index % 4) / 4,
        )!.withValues(alpha: 0.78 * visibility)
        ..strokeWidth = size.shortestSide * 0.008
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(base.dx, base.dy)
        ..cubicTo(
          base.dx - size.width * 0.02,
          base.dy - height * 0.32,
          base.dx + wiggle,
          base.dy - height * 0.7,
          base.dx + wiggle * 0.6,
          base.dy - height,
        );
      canvas.drawPath(path, paint);
    }

    final particleCount = 22;
    for (var index = 0; index < particleCount; index++) {
      final lifetime = (burst * 1.15 + index * 0.043) % 1.0;
      final x = size.width * ((0.06 + index * 0.044) % 0.96);
      final y = size.height * (0.92 - lifetime * 0.78);
      final radius = size.shortestSide * (0.005 + (index % 3) * 0.0028);
      final alpha =
          (1 - lifetime) * 0.7 * visibility * (0.6 + 0.4 * grow);
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = ReefColors.brightAlgae.withValues(
            alpha: alpha.clamp(0.0, 1.0),
          ),
      );
    }
  }

  void _paintFishBurst(Canvas canvas, Size size) {
    final fadeOut = ((1 - burst) / 0.12).clamp(0.0, 1.0);
    final floorY = size.height * 0.81;
    final fishColors = [
      ReefColors.reefGold,
      ReefColors.softCoral,
      const Color(0xFF82D4E3),
      const Color(0xFFFFC658),
    ];

    final targets = [
      Offset(size.width * 0.20, floorY + size.height * 0.02),
      Offset(size.width * 0.45, floorY),
      Offset(size.width * 0.72, floorY + size.height * 0.02),
      Offset(size.width * 0.90, floorY),
    ];

    for (var i = 0; i < targets.length; i++) {
      final target = targets[i];
      final delay = i * 0.05;
      final localProgress = ((burst - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (localProgress <= 0) {
        continue;
      }

      final maxAlgaeHeight = size.height * 0.13;
      final consume = ((localProgress - 0.30) / 0.20).clamp(0.0, 1.0);
      final algaeRemaining = 1 - consume;
      if (algaeRemaining > 0.02) {
        _drawSingleAlga(
          canvas,
          target,
          maxAlgaeHeight * algaeRemaining,
          fadeOut * 0.95,
        );
      }

      final fromLeft = i.isEven;
      final approachStart = Offset(
        fromLeft ? -size.width * 0.05 : size.width * 1.05,
        size.height * (0.28 + (i % 3) * 0.08),
      );
      final eatPos = target.translate(0, -size.height * 0.05);
      final exitX = fromLeft ? size.width * 1.12 : -size.width * 0.12;
      final exitOffset = Offset(
        exitX,
        size.height * (0.22 + (i % 3) * 0.06),
      );

      Offset fishPos;
      bool eating = false;
      bool facingRight;

      if (localProgress < 0.30) {
        final phase = localProgress / 0.30;
        final eased = Curves.easeInOutCubic.transform(phase);
        fishPos = Offset.lerp(approachStart, eatPos, eased)!;
        facingRight = approachStart.dx < eatPos.dx;
      } else if (localProgress < 0.55) {
        eating = true;
        final wiggle =
            math.sin(time * math.pi * 18 + i) * size.width * 0.005;
        final bob =
            math.sin(time * math.pi * 14 + i) * size.height * 0.008;
        fishPos = eatPos.translate(wiggle, bob);
        facingRight = approachStart.dx < eatPos.dx;
      } else {
        final phase = (localProgress - 0.55) / 0.45;
        final eased = Curves.easeInCubic.transform(phase);
        fishPos = Offset.lerp(eatPos, exitOffset, eased)!;
        facingRight = eatPos.dx < exitOffset.dx;
      }

      final fishSize = size.shortestSide * 0.044;
      final body = fishColors[i % fishColors.length];
      final accent = fishColors[(i + 1) % fishColors.length];

      _drawFish(
        canvas,
        fishPos,
        fishSize,
        facingRight: facingRight,
        body: body.withValues(alpha: fadeOut),
        accent: accent.withValues(alpha: fadeOut * 0.92),
        happy: true,
      );

      if (eating) {
        final mouthSign = facingRight ? 1 : -1;
        final mouthCenter = Offset(
          fishPos.dx + mouthSign * fishSize * 1.0,
          fishPos.dy + size.height * 0.005,
        );
        final pulse =
            (math.sin(time * math.pi * 22 + i) * 0.5 + 0.5).toDouble();
        canvas.drawCircle(
          mouthCenter,
          fishSize * (0.22 + pulse * 0.18),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.shortestSide * 0.0045
            ..color = ReefColors.brightAlgae.withValues(
              alpha: 0.6 * fadeOut,
            ),
        );

        for (var bite = 0; bite < 4; bite++) {
          final biteAge =
              ((time * 4 + bite * 0.25 + i * 0.13) % 1).toDouble();
          final biteX =
              mouthCenter.dx - mouthSign * biteAge * size.width * 0.04;
          final biteY = mouthCenter.dy +
              math.sin(time * math.pi * 10 + bite + i) * size.height * 0.012;
          canvas.drawCircle(
            Offset(biteX, biteY),
            (size.shortestSide * 0.005) * (1 - biteAge),
            Paint()
              ..color = ReefColors.brightAlgae.withValues(
                alpha: (0.85 - biteAge) * fadeOut,
              ),
          );
        }
      }
    }
  }

  void _paintCrabBurst(Canvas canvas, Size size) {
    final fadeOut = ((1 - burst) / 0.12).clamp(0.0, 1.0);
    final floorY = size.height * 0.88;

    final scenes = <_CrabSceneSetup>[
      _CrabSceneSetup(crabX: 0.23, algaeX: 0.30, side: 1.0),
      _CrabSceneSetup(crabX: 0.55, algaeX: 0.46, side: -1.0),
      _CrabSceneSetup(crabX: 0.78, algaeX: 0.86, side: 1.0),
    ];
    const snipsTotal = 4;

    for (var i = 0; i < scenes.length; i++) {
      final scene = scenes[i];
      final restX = scene.crabX * size.width;
      final algaeX = scene.algaeX * size.width;
      final side = scene.side;

      final delay = i * 0.06;
      final localProgress =
          ((burst - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (localProgress <= 0) {
        continue;
      }

      final crabAppear = (localProgress / 0.12).clamp(0.0, 1.0);
      final crabScale = Curves.easeOutBack.transform(crabAppear);
      final crabSize = size.shortestSide * 0.05 * crabScale;

      final cuttingPhase =
          ((localProgress - 0.12) / 0.78).clamp(0.0, 1.0);
      final cumulative = cuttingPhase * snipsTotal;
      final snipsCompleted = cumulative.floor();
      final snipFrac = cumulative - snipsCompleted;
      final clawClosure = (1 - 2 * (snipFrac - 0.5).abs()).clamp(0.0, 1.0);

      final algaeRemaining =
          (1 - snipsCompleted / snipsTotal).clamp(0.0, 1.0);
      final maxAlgaeHeight = size.height * 0.13;
      final algaeHeight = maxAlgaeHeight * algaeRemaining;

      if (algaeHeight > 0 && algaeRemaining > 0.02) {
        _drawSingleAlga(
          canvas,
          Offset(algaeX, floorY),
          algaeHeight,
          fadeOut * 0.95,
        );
      }

      if (snipsCompleted > 0 && snipFrac < 0.7 && cuttingPhase < 1.0) {
        final pieceProgress = (snipFrac / 0.7).clamp(0.0, 1.0);
        final pieceY = floorY - algaeHeight - 16 - pieceProgress * 32;
        final pieceX = algaeX + side * pieceProgress * 26;
        _drawAlgaeFragment(
          canvas,
          Offset(pieceX, pieceY),
          18,
          (1 - pieceProgress) * fadeOut * 0.9,
          (pieceProgress - 0.5) * 0.9 * side,
        );
      }

      final snipPosX = algaeX - side * (crabSize * 1.6);
      final currentCrabX = restX + (snipPosX - restX) * clawClosure;
      final crabPos = Offset(currentCrabX, floorY);

      final armStart = Offset(
        crabPos.dx + side * crabSize * 0.55,
        crabPos.dy - crabSize * 0.6,
      );
      final clawCenter = Offset(
        algaeX - side * (crabSize * 0.4 + clawClosure * crabSize * 0.1),
        floorY - algaeHeight - 4,
      );

      if (clawClosure > 0.55 && algaeHeight > 0) {
        final flash = (clawClosure - 0.55) / 0.45;
        canvas.drawLine(
          Offset(algaeX - 14, floorY - algaeHeight - 2),
          Offset(algaeX + 14, floorY - algaeHeight + 4),
          Paint()
            ..color = Colors.white.withValues(
              alpha: flash * 0.85 * fadeOut,
            )
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6
            ..strokeCap = StrokeCap.round,
        );
      }

      _drawCrab(canvas, crabPos, crabSize, i + 100);

      final armPaint = Paint()
        ..color = ReefColors.coral.withValues(alpha: fadeOut)
        ..strokeWidth = crabSize * 0.28
        ..strokeCap = StrokeCap.round;
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
          ..color = const Color(0xFF8E2D35).withValues(alpha: fadeOut)
          ..style = PaintingStyle.stroke
          ..strokeWidth = armPaint.strokeWidth + 1.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        armPath,
        Paint()
          ..color = ReefColors.coral.withValues(alpha: fadeOut)
          ..style = PaintingStyle.stroke
          ..strokeWidth = armPaint.strokeWidth
          ..strokeCap = StrokeCap.round,
      );

      _drawScissorClaw(
        canvas,
        clawCenter,
        crabSize * 1.0,
        side,
        1 - clawClosure,
        fadeOut,
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
    final wiggle = math.sin(time * math.pi * 4 + base.dx) * 6;
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
    double alpha,
  ) {
    if (alpha <= 0) {
      return;
    }
    final fillPaint = Paint()
      ..color = ReefColors.coral.withValues(alpha: alpha);
    final outlinePaint = Paint()
      ..color = const Color(0xFF8E2D35).withValues(alpha: alpha)
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
    canvas.drawPath(upper, fillPaint);
    canvas.drawPath(upper, outlinePaint);

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
    canvas.drawPath(lower, fillPaint);
    canvas.drawPath(lower, outlinePaint);

    canvas.restore();
  }

  void _drawCoral(
    Canvas canvas,
    Offset base,
    double scale,
    Color color,
    int index,
  ) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.92)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = scale * 0.18;
    final sway = math.sin(time * math.pi * 2 + index) * scale * 0.12;

    canvas.drawLine(base, base.translate(sway, -scale * 1.55), paint);
    canvas.drawLine(
      base.translate(sway * 0.3, -scale * 0.65),
      base.translate(-scale * 0.82 + sway, -scale * 1.12),
      paint,
    );
    canvas.drawLine(
      base.translate(sway * 0.2, -scale * 0.94),
      base.translate(scale * 0.76 + sway, -scale * 1.38),
      paint,
    );
    canvas.drawCircle(base.translate(sway, -scale * 1.62), scale * 0.18, paint);
  }

  void _drawFish(
    Canvas canvas,
    Offset center,
    double size, {
    required bool facingRight,
    required Color body,
    required Color accent,
    bool happy = true,
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
    if (happy) {
      canvas.drawCircle(
        Offset(size * 0.62, -size * 0.16),
        size * 0.12,
        inkPaint,
      );
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
    } else {
      final eyePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.07
        ..strokeCap = StrokeCap.round
        ..color = ReefColors.ink.withValues(alpha: 0.86);
      canvas.drawLine(
        Offset(size * 0.55, -size * 0.22),
        Offset(size * 0.69, -size * 0.10),
        eyePaint,
      );
      canvas.drawLine(
        Offset(size * 0.69, -size * 0.22),
        Offset(size * 0.55, -size * 0.10),
        eyePaint,
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size * 0.78, size * 0.27),
          width: size * 0.45,
          height: size * 0.26,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * 0.07
          ..strokeCap = StrokeCap.round
          ..color = ReefColors.ink.withValues(alpha: 0.6),
      );
    }
    canvas.restore();
  }

  void _drawCrab(Canvas canvas, Offset center, double size, int index) {
    final bodyPaint = Paint()..color = ReefColors.coral;
    final accentPaint = Paint()..color = ReefColors.softCoral;
    final linePaint = Paint()
      ..color = const Color(0xFF8E2D35)
      ..strokeWidth = size * 0.13
      ..strokeCap = StrokeCap.round;
    final clawPaint = Paint()..color = ReefColors.coral;
    final eyePaint = Paint()..color = ReefColors.paper;
    final pupilPaint = Paint()..color = ReefColors.ink.withValues(alpha: 0.78);
    final step = math.sin(time * math.pi * 8 + index) * size * 0.12;

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
      _drawCrabClaw(
        canvas,
        center.translate(direction * size * 1.62, -size * 0.98 + step),
        size,
        direction,
        clawPaint,
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

  void _drawCrabClaw(
    Canvas canvas,
    Offset center,
    double size,
    double direction,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(direction, 1);

    final upper = Path()
      ..moveTo(-size * 0.14, size * 0.06)
      ..quadraticBezierTo(size * 0.32, -size * 0.72, size * 0.9, -size * 0.48)
      ..quadraticBezierTo(size * 0.74, -size * 0.06, size * 0.2, size * 0.16)
      ..close();
    final lower = Path()
      ..moveTo(-size * 0.02, size * 0.14)
      ..quadraticBezierTo(size * 0.54, size * 0.18, size * 0.82, size * 0.62)
      ..quadraticBezierTo(size * 0.2, size * 0.7, -size * 0.2, size * 0.26)
      ..close();

    canvas.drawPath(upper, paint);
    canvas.drawPath(lower, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ReefScenePainter oldDelegate) {
    return oldDelegate.reef != reef ||
        oldDelegate.time != time ||
        oldDelegate.burst != burst;
  }
}

class _CrabSceneSetup {
  const _CrabSceneSetup({
    required this.crabX,
    required this.algaeX,
    required this.side,
  });

  final double crabX;
  final double algaeX;
  final double side;
}
