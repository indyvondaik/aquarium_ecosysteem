import 'dart:math' as math;

import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/application/reef_sound_service.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_action.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_scene.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_scene_layout.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_life_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ReefSceneTapCallback = void Function(double x, double y);

class ReefScenePanel extends ConsumerStatefulWidget {
  const ReefScenePanel({
    required this.reef,
    required this.onTap,
    required this.compact,
    this.decorative = false,
    super.key,
  });

  final ReefState reef;
  final ReefSceneTapCallback onTap;
  final bool compact;

  /// Als `true`: gebruikt als achtergrond op het startscherm. Geen hit-tests,
  /// geen population/action/result overlays — alleen het water met bubbel-tap.
  final bool decorative;

  @override
  ConsumerState<ReefScenePanel> createState() => _ReefScenePanelState();
}

class _ReefScenePanelState extends ConsumerState<ReefScenePanel>
    with TickerProviderStateMixin {
  late final AnimationController _swimController;
  late final AnimationController _burstController;
  late final AnimationController _interactionTicker;
  final Stopwatch _clock = Stopwatch()..start();

  final List<_BubbleBurst> _bubbles = <_BubbleBurst>[];
  final Map<int, FishDartState> _fishDarts = <int, FishDartState>{};
  final Map<int, CrabSnipState> _crabSnips = <int, CrabSnipState>{};
  final Map<int, AlgaeDanceState> _algaeDances = <int, AlgaeDanceState>{};

  int _nextBubbleId = 0;
  late int _lastReefEventId;

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
    _interactionTicker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onInteractionTick);
    _lastReefEventId = widget.reef.eventId;
  }

  @override
  void didUpdateWidget(covariant ReefScenePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reef.eventId != _lastReefEventId) {
      _lastReefEventId = widget.reef.eventId;
      _burstController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _interactionTicker
      ..removeListener(_onInteractionTick)
      ..dispose();
    _swimController.dispose();
    _burstController.dispose();
    _clock.stop();
    super.dispose();
  }

  void _onInteractionTick() {
    final now = _clock.elapsed;
    _bubbles.removeWhere((effect) => now >= effect.endsAt);
    _fishDarts.removeWhere(
      (_, dart) => now - dart.startedAt >= FishDartState.total,
    );
    _crabSnips.removeWhere(
      (_, snip) => now - snip.startedAt >= CrabSnipState.duration,
    );
    _algaeDances.removeWhere(
      (_, dance) => now - dance.startedAt >= AlgaeDanceState.duration,
    );

    final hasWork = _bubbles.isNotEmpty ||
        _fishDarts.isNotEmpty ||
        _crabSnips.isNotEmpty ||
        _algaeDances.isNotEmpty;
    if (!hasWork) {
      _interactionTicker.stop();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _ensureTicker() {
    if (!_interactionTicker.isAnimating) {
      _interactionTicker.repeat();
    }
  }

  void _handleTap(Offset position, Size size) {
    final now = _clock.elapsed;
    final sounds = ref.read(reefSoundServiceProvider);

    if (widget.decorative) {
      _spawnBubbleBurst(position, now);
      sounds.play(ReefSoundEffect.bubblePop);
      _ensureTicker();
      return;
    }

    final time = _swimController.value;
    final layout = ReefSceneLayout.compute(
      reef: widget.reef,
      size: size,
      time: time,
    );
    final hit = layout.hitTest(position);

    switch (hit) {
      case FishHit(:final index):
        _startFishDart(index, layout, size, now);
        sounds.play(ReefSoundEffect.bubblePop, volume: 0.55);
      case CrabHit(:final index):
        // Tweede knip op dezelfde krab? Reset zodat hij opnieuw start.
        _crabSnips[index] = CrabSnipState(index: index, startedAt: now);
        sounds.play(ReefSoundEffect.sandPuff, volume: 0.55);
      case AlgaeHit(:final index):
        _algaeDances[index] = AlgaeDanceState(index: index, startedAt: now);
        sounds.play(ReefSoundEffect.sparkle, volume: 0.45);
      case null:
        _spawnBubbleBurst(position, now);
        sounds.play(ReefSoundEffect.bubblePop);
    }

    _ensureTicker();

    // Behoud de bestaande ripple ring via controller — geeft visuele feedback
    // op exact de tap-locatie ongeacht of er iets geraakt werd.
    widget.onTap(position.dx / size.width, position.dy / size.height);
  }

  void _startFishDart(
    int index,
    ReefSceneLayout layout,
    Size size,
    Duration now,
  ) {
    if (index >= layout.fish.length) {
      return;
    }
    final fish = layout.fish[index];
    // Dart in de richting weg van het centrum naar buiten beeld.
    final cx = size.width / 2;
    final cy = size.height / 2;
    final awayX = fish.center.dx - cx;
    final awayY = (fish.center.dy - cy) * 0.4 - size.height * 0.05;
    final mag = math.sqrt(awayX * awayX + awayY * awayY);
    final unitX = mag > 0.5 ? awayX / mag : (fish.facingRight ? 1.0 : -1.0);
    final unitY = mag > 0.5 ? awayY / mag : -0.3;
    final dist = size.shortestSide * 1.4;
    final exit = Offset(
      fish.center.dx + unitX * dist,
      fish.center.dy + unitY * dist,
    );
    // Nieuwe vis komt van de natuurlijke entry-rand (gebaseerd op facingRight).
    final entryX = fish.facingRight
        ? -fish.size * 3
        : size.width + fish.size * 3;
    final entryFrom = Offset(entryX, fish.center.dy);

    _fishDarts[index] = FishDartState(
      index: index,
      startedAt: now,
      startPosition: fish.center,
      startFacingRight: fish.facingRight,
      exitTarget: exit,
      entryFrom: entryFrom,
    );
  }

  void _spawnBubbleBurst(Offset position, Duration now) {
    _bubbles.add(
      _BubbleBurst(
        id: _nextBubbleId++,
        position: position,
        startedAt: now,
        duration: const Duration(milliseconds: 1100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final interactions = ReefSceneInteractions(
      fishDarts: _fishDarts,
      crabSnips: _crabSnips,
      algaeDances: _algaeDances,
    );
    return ColoredBox(
      color: ReefColors.deepSea,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  _handleTap(details.localPosition, size),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _swimController,
                      _burstController,
                      _interactionTicker,
                    ]),
                    builder: (context, _) {
                      return ReefScene(
                        reef: widget.reef,
                        time: _swimController.value,
                        burst: _burstController.value,
                        now: _clock.elapsed,
                        interactions: interactions,
                        showInhabitants: !widget.decorative,
                      );
                    },
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x05000000),
                          Color(0x110E3557),
                          Color(0x66051F36),
                        ],
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _BubbleBurstPainter(
                        bursts: List<_BubbleBurst>.unmodifiable(_bubbles),
                        now: _clock.elapsed,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                  if (!widget.decorative)
                    Positioned(
                      top: widget.compact ? 112 : 140,
                      left: widget.compact ? 10 : 18,
                      child: _PopulationCluster(
                        reef: widget.reef,
                        compact: widget.compact,
                      ),
                    ),
                  if (!widget.decorative && widget.reef.lastAction != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _ActionSplash(reef: widget.reef),
                      ),
                    ),
                  if (!widget.decorative && widget.reef.resultVisible)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _ResultPulse(reef: widget.reef),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BubbleBurst {
  _BubbleBurst({
    required this.id,
    required this.position,
    required this.startedAt,
    required this.duration,
  });

  final int id;
  final Offset position;
  final Duration startedAt;
  final Duration duration;

  Duration get endsAt => startedAt + duration;

  double progressAt(Duration now) {
    final elapsed = now - startedAt;
    final ratio = elapsed.inMicroseconds / duration.inMicroseconds;
    return ratio.clamp(0.0, 1.0);
  }
}

class _BubbleBurstPainter extends CustomPainter {
  const _BubbleBurstPainter({required this.bursts, required this.now});

  final List<_BubbleBurst> bursts;
  final Duration now;

  @override
  void paint(Canvas canvas, Size size) {
    for (final burst in bursts) {
      final progress = burst.progressAt(now);
      if (progress >= 1.0) {
        continue;
      }
      _paintBurst(canvas, size, burst, progress);
    }
  }

  void _paintBurst(
    Canvas canvas,
    Size size,
    _BubbleBurst burst,
    double progress,
  ) {
    final fade = (1 - progress * 0.85).clamp(0.0, 1.0);
    final rise = Curves.easeOutQuad.transform(progress);
    final base = burst.position;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, size.shortestSide * 0.0025)
      ..color = Colors.white.withValues(alpha: fade * 0.78);
    final fillPaint = Paint()
      ..color = ReefColors.water.withValues(alpha: fade * 0.36);

    for (var i = 0; i < 6; i++) {
      final seed = (burst.id * 0.31 + i * 0.71) % 1;
      final sway = math.sin(progress * math.pi * 3 + i + burst.id) *
          size.shortestSide *
          0.018;
      final localRise = (rise + i * 0.07).clamp(0.0, 1.0);
      final offset = Offset(
        base.dx + sway + (i - 2.5) * size.shortestSide * 0.012,
        base.dy -
            localRise * size.height * 0.22 -
            i * size.shortestSide * 0.012,
      );
      final radius = size.shortestSide *
          (0.011 + seed * 0.013) *
          (1 - progress * 0.25);
      canvas.drawCircle(offset, radius, fillPaint);
      canvas.drawCircle(offset, radius, strokePaint);
      canvas.drawCircle(
        offset.translate(-radius * 0.35, -radius * 0.35),
        radius * 0.28,
        Paint()..color = Colors.white.withValues(alpha: fade * 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubbleBurstPainter oldDelegate) {
    return oldDelegate.now != now || oldDelegate.bursts != bursts;
  }
}

class _PopulationCluster extends StatelessWidget {
  const _PopulationCluster({required this.reef, required this.compact});

  final ReefState reef;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricChipData(
        label: 'Algen',
        value: _algaeLevel(reef.algae),
        icon: ReefLifeIconType.algae,
      ),
      _MetricChipData(
        label: 'Vissen',
        value: _fishLevel(reef.fish),
        icon: ReefLifeIconType.fish,
      ),
      _MetricChipData(
        label: 'Krabben',
        value: _crabLevel(reef.crab),
        icon: ReefLifeIconType.crab,
      ),
    ];

    return SizedBox(
      width: compact ? 178 : 208,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            _MetricChip(metric: metrics[index], compact: compact),
            if (index != metrics.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _MetricChipData {
  const _MetricChipData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final ReefLifeIconType icon;
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.metric, required this.compact});

  final _MetricChipData metric;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: ReefColors.paper.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ReefColors.navy, width: 1.2),
      ),
      child: Row(
        children: [
          ReefLifeIcon(
            type: metric.icon,
            size: compact ? 16 : 18,
            color: ReefColors.navy,
            accentColor: ReefColors.purple.withValues(alpha: 0.72),
            semanticLabel: metric.label,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${metric.label}:',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ReefTypography.condensed(
                size: compact ? 11 : 12,
                color: ReefColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            metric.value,
            maxLines: 1,
            textAlign: TextAlign.right,
            style: ReefTypography.condensed(
              size: compact ? 11 : 12,
              color: ReefColors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSplash extends StatelessWidget {
  const _ActionSplash({required this.reef});

  final ReefState reef;

  @override
  Widget build(BuildContext context) {
    final action = reef.lastAction;
    if (action == null) {
      return const SizedBox.shrink();
    }

    final visual = _ActionVisual.from(action);

    return TweenAnimationBuilder<double>(
      key: ValueKey('splash-${reef.eventId}-${reef.lastAction}'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 920),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final baseX = reef.rippleX.clamp(0.18, 0.82);
            final baseY = reef.rippleY.clamp(0.18, 0.82);
            final labelLeft = (width * baseX - 86)
                .clamp(12.0, width - 176.0)
                .toDouble();
            final labelTop = (height * baseY - 120 - value * 36)
                .clamp(18.0, height - 42.0)
                .toDouble();

            return Stack(
              children: [
                Positioned(
                  left: labelLeft,
                  top: labelTop,
                  child: Opacity(
                    opacity: (1 - value * 1.1).clamp(0.0, 1.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: ReefColors.paper.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: ReefColors.navy, width: 1.2),
                      ),
                      child: Text(
                        action.buttonLabel,
                        style: ReefTypography.condensed(
                          size: 12,
                          color: ReefColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
                for (var index = 0; index < 4; index++)
                  Positioned(
                    left: (width * baseX + (index - 1.5) * 30 * (0.6 + value))
                        .clamp(12.0, width - 40.0)
                        .toDouble(),
                    top: (height * baseY - 20 - value * 110 - index * 10)
                        .clamp(16.0, height - 40.0)
                        .toDouble(),
                    child: Opacity(
                      opacity: (1 - value).clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: (index - 1.5) * 0.2 * (1 - value),
                        child: Transform.scale(
                          scale: 0.7 + value * 0.45,
                          child: ReefLifeIcon(
                            type: visual.type,
                            size: 22 + index.toDouble(),
                            color: visual.color.withValues(
                              alpha: 0.9 - value * 0.3,
                            ),
                            accentColor: visual.color.withValues(
                              alpha: 0.5 - value * 0.1,
                            ),
                            semanticLabel: visual.semanticLabel,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ResultPulse extends StatelessWidget {
  const _ResultPulse({required this.reef});

  final ReefState reef;

  @override
  Widget build(BuildContext context) {
    final color = reef.solvedRound
        ? ReefColors.brightAlgae
        : ReefColors.softCoral;

    return TweenAnimationBuilder<double>(
      key: ValueKey('pulse-${reef.eventId}-${reef.solvedRound}'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 860),
      curve: Curves.easeOutQuad,
      builder: (context, value, _) {
        return Opacity(
          opacity: (1 - value) * 0.68,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(reef.rippleX * 2 - 1, reef.rippleY * 2 - 1),
                radius: 0.18 + value * 0.9,
                colors: [color.withValues(alpha: 0.42), Colors.transparent],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionVisual {
  const _ActionVisual({
    required this.type,
    required this.color,
    required this.semanticLabel,
  });

  final ReefLifeIconType type;
  final Color color;
  final String semanticLabel;

  factory _ActionVisual.from(ReefAction action) {
    return switch (action) {
      ReefAction.algae => const _ActionVisual(
        type: ReefLifeIconType.algae,
        color: ReefColors.brightAlgae,
        semanticLabel: 'Alg',
      ),
      ReefAction.fish => const _ActionVisual(
        type: ReefLifeIconType.fish,
        color: ReefColors.reefGold,
        semanticLabel: 'Vis',
      ),
      ReefAction.crab => const _ActionVisual(
        type: ReefLifeIconType.crab,
        color: ReefColors.softCoral,
        semanticLabel: 'Krab',
      ),
    };
  }
}

String _algaeLevel(int value) {
  if (value <= 26) {
    return 'weinig';
  }
  if (value >= 76) {
    return 'veel';
  }
  return 'goed';
}

String _fishLevel(int value) {
  if (value <= 40) {
    return 'laag';
  }
  if (value >= 72) {
    return 'veel';
  }
  return 'goed';
}

String _crabLevel(int value) {
  if (value <= 10) {
    return 'laag';
  }
  if (value >= 30) {
    return 'hoog';
  }
  return 'aanwezig';
}
