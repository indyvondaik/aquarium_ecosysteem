import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_action.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_scene.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_life_icon.dart';
import 'package:flutter/material.dart';

typedef ReefSceneTapCallback = void Function(double x, double y);

class ReefScenePanel extends StatelessWidget {
  const ReefScenePanel({
    required this.reef,
    required this.onTap,
    required this.compact,
    super.key,
  });

  final ReefState reef;
  final ReefSceneTapCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ReefColors.deepSea,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                onTap(
                  details.localPosition.dx / constraints.maxWidth,
                  details.localPosition.dy / constraints.maxHeight,
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ReefScene(reef: reef),
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
                  Positioned(
                    top: compact ? 112 : 140,
                    left: compact ? 10 : 18,
                    child: _PopulationCluster(reef: reef, compact: compact),
                  ),
                  if (reef.lastAction != null)
                    Positioned.fill(
                      child: IgnorePointer(child: _ActionSplash(reef: reef)),
                    ),
                  if (reef.resultVisible)
                    Positioned.fill(
                      child: IgnorePointer(child: _ResultPulse(reef: reef)),
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
