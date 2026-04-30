import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_action.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_scene.dart';
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: ReefColors.deepSea,
        border: Border.all(color: ReefColors.line, width: 2),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x240A2540),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final messageWidth = compact
                ? constraints.maxWidth - 28
                : (constraints.maxWidth * 0.55).clamp(300, 520).toDouble();

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
                    top: compact ? 12 : 18,
                    left: compact ? 12 : 18,
                    child: _SceneBadgeCluster(reef: reef, compact: compact),
                  ),
                  Positioned(
                    top: compact ? 12 : 18,
                    right: compact ? 12 : 18,
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
                  Positioned(
                    left: compact ? 14 : 20,
                    bottom: compact ? 14 : 20,
                    width: messageWidth,
                    child: _SceneMessage(reef: reef, compact: compact),
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

class _SceneBadgeCluster extends StatelessWidget {
  const _SceneBadgeCluster({required this.reef, required this.compact});

  final ReefState reef;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = switch (reef.phase) {
      ReefRoundPhase.intro => ReefColors.seaFoam,
      ReefRoundPhase.reaction => ReefColors.reefGold,
      ReefRoundPhase.result =>
        reef.solvedRound ? ReefColors.brightAlgae : ReefColors.softCoral,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SceneChip(
          icon: Icons.waves_rounded,
          label: reef.stepLabel,
          color: accent,
          compact: compact,
        ),
        const SizedBox(height: 8),
        _SceneChip(
          icon: _iconForMood(reef),
          label: reef.sceneStatus,
          color: ReefColors.paper,
          compact: compact,
        ),
      ],
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
        icon: Icons.spa_rounded,
      ),
      _MetricChipData(
        label: 'Vis',
        value: _fishLevel(reef.fish),
        icon: Icons.set_meal_rounded,
      ),
      _MetricChipData(
        label: 'Krab',
        value: _crabLevel(reef.crab),
        icon: Icons.cleaning_services_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var index = 0; index < metrics.length; index++) ...[
          _MetricChip(metric: metrics[index], compact: compact),
          if (index != metrics.length - 1) const SizedBox(height: 8),
        ],
      ],
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
  final IconData icon;
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
        color: ReefColors.paper.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ReefColors.line, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(metric.icon, size: compact ? 16 : 18, color: ReefColors.ink),
          const SizedBox(width: 6),
          Text(
            '${metric.label}: ${metric.value}',
            style: ReefTypography.condensed(
              size: compact ? 11 : 12,
              color: ReefColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneMessage extends StatelessWidget {
  const _SceneMessage({required this.reef, required this.compact});

  final ReefState reef;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForMood(reef);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInCubic,
      child: Container(
        key: ValueKey('${reef.eventId}-${reef.observationTitle}'),
        padding: EdgeInsets.fromLTRB(
          compact ? 12 : 16,
          compact ? 12 : 14,
          compact ? 12 : 16,
          compact ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: ReefColors.paper.withValues(alpha: 0.94),
          border: Border.all(color: ReefColors.line, width: 1.6),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: compact ? 38 : 44,
                  height: compact ? 38 : 44,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: ReefColors.line, width: 1.2),
                  ),
                  child: Icon(_iconForMood(reef), color: ReefColors.ink),
                ),
                SizedBox(width: compact ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reef.isResult
                            ? 'RESULTAAT'
                            : reef.isIntro
                            ? 'STARTBEELD'
                            : 'WAT VALT JE OP?',
                        style: ReefTypography.condensed(
                          size: compact ? 12 : 13,
                          color: ReefColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reef.observationTitle.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ReefTypography.condensed(
                          size: compact ? 16 : 20,
                          color: ReefColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              reef.observationDetail,
              maxLines: compact ? 3 : 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ReefColors.ink,
                fontSize: compact ? 12 : 14,
                height: 1.26,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            if (reef.isResult) ...[
              const SizedBox(height: 10),
              Text(
                reef.autoResetLabel,
                style: TextStyle(
                  color: ReefColors.navy,
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SceneChip extends StatelessWidget {
  const _SceneChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ReefColors.line, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 16 : 18, color: ReefColors.ink),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: ReefTypography.condensed(
              size: compact ? 12 : 13,
              color: ReefColors.ink,
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
                        border: Border.all(color: ReefColors.line, width: 1.2),
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
                          child: Icon(
                            visual.icon,
                            size: 22 + index.toDouble(),
                            color: visual.color.withValues(
                              alpha: 0.9 - value * 0.3,
                            ),
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
  const _ActionVisual({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  factory _ActionVisual.from(ReefAction action) {
    return switch (action) {
      ReefAction.algae => const _ActionVisual(
        icon: Icons.spa_rounded,
        color: ReefColors.brightAlgae,
      ),
      ReefAction.fish => const _ActionVisual(
        icon: Icons.set_meal_rounded,
        color: ReefColors.reefGold,
      ),
      ReefAction.crab => const _ActionVisual(
        icon: Icons.cleaning_services_rounded,
        color: ReefColors.softCoral,
      ),
    };
  }
}

Color _accentForMood(ReefState reef) {
  return switch (reef.mood) {
    ReefMood.algaeBloom => ReefColors.brightAlgae,
    ReefMood.hungry => ReefColors.reefGold,
    ReefMood.overCleaned => ReefColors.softCoral,
    ReefMood.crowded => ReefColors.softCoral,
    ReefMood.thriving => ReefColors.brightAlgae,
    ReefMood.balanced => ReefColors.water,
  };
}

IconData _iconForMood(ReefState reef) {
  return switch (reef.mood) {
    ReefMood.algaeBloom => Icons.spa_rounded,
    ReefMood.hungry => Icons.no_meals_rounded,
    ReefMood.overCleaned => Icons.cleaning_services_rounded,
    ReefMood.crowded => Icons.waves_rounded,
    ReefMood.thriving => Icons.auto_awesome_rounded,
    ReefMood.balanced => Icons.favorite_rounded,
  };
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
