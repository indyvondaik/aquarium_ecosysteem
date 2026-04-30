import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_action.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:flutter/material.dart';

class ReefInfoPanel extends StatelessWidget {
  const ReefInfoPanel({required this.reef, required this.compact, super.key});

  final ReefState reef;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ReefColors.paper.withValues(alpha: 0.98),
            ReefColors.seaFoam.withValues(alpha: 0.94),
          ],
        ),
        border: Border.all(color: ReefColors.line, width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.all(compact ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 40 : 46,
                height: compact ? 40 : 46,
                decoration: BoxDecoration(
                  color: ReefColors.purple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.visibility_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WAT VALT JE OP?',
                      style: ReefTypography.condensed(size: compact ? 13 : 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reef.observationTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ReefTypography.condensed(
                        size: compact ? 17 : 18,
                        color: ReefColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _accentForMood(reef).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Ronde ${reef.roundNumber}',
                  style: ReefTypography.condensed(
                    size: 12,
                    color: ReefColors.ink,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 12 : 14),
          _ObservationCard(reef: reef, compact: compact),
          SizedBox(height: compact ? 10 : 12),
          _GuideCard(reef: reef, compact: compact),
          SizedBox(height: compact ? 10 : 12),
          _RoundProgress(reef: reef, compact: compact),
        ],
      ),
    );
  }
}

class _ObservationCard extends StatelessWidget {
  const _ObservationCard({required this.reef, required this.compact});

  final ReefState reef;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForMood(reef);

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 38 : 42,
            height: compact ? 38 : 42,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: Icon(_iconForMood(reef), color: ReefColors.ink),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reef.observationDetail,
              style: TextStyle(
                color: ReefColors.ink,
                fontSize: compact ? 12 : 14,
                height: 1.26,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.reef, required this.compact});

  final ReefState reef;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Container(
        key: ValueKey('${reef.phase}-${reef.firstAction}-${reef.lastAction}'),
        padding: EdgeInsets.all(compact ? 12 : 14),
        decoration: BoxDecoration(
          color: ReefColors.deepSea,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _guideTitle(reef),
              style: ReefTypography.condensed(
                size: compact ? 13 : 14,
                color: ReefColors.reefGold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _guideBody(reef),
              style: TextStyle(
                color: ReefColors.paper.withValues(alpha: 0.92),
                fontSize: compact ? 12 : 13,
                height: 1.25,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundProgress extends StatelessWidget {
  const _RoundProgress({required this.reef, required this.compact});

  final ReefState reef;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final steps = ['Start', 'Kijk', 'Resultaat'];
    final currentStep = switch (reef.phase) {
      ReefRoundPhase.intro => 0,
      ReefRoundPhase.reaction => 1,
      ReefRoundPhase.result => 2,
    };

    return Row(
      children: [
        for (var index = 0; index < steps.length; index++) ...[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: compact ? 10 : 12,
                  decoration: BoxDecoration(
                    color: index <= currentStep
                        ? ReefColors.lagoon
                        : ReefColors.seaFoam,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  steps[index].toUpperCase(),
                  style: ReefTypography.condensed(
                    size: compact ? 11 : 12,
                    color: index <= currentStep
                        ? ReefColors.ink
                        : ReefColors.navy.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          if (index != steps.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
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

String _guideTitle(ReefState reef) {
  if (reef.isIntro) {
    return 'START';
  }

  if (reef.isReaction) {
    return 'SLIMME HINT';
  }

  return reef.solvedRound ? 'GOED GEZIEN' : 'PROBEER HET NOG EENS';
}

String _guideBody(ReefState reef) {
  if (reef.isIntro) {
    return 'Verander het rif eerst met algen, vissen of krabben. Daarna kies je 1 oplossing.';
  }

  if (reef.isReaction) {
    return switch (reef.highlightedAction) {
      ReefAction.fish =>
        'Zie je veel groen? Kies meer vissen. Zij eten de extra algen weg.',
      ReefAction.algae when reef.firstAction == ReefAction.fish =>
        'De vissen kregen te weinig eten. Kies algen zodat er weer voedsel is.',
      ReefAction.algae when reef.firstAction == ReefAction.crab =>
        'Het rif is te schoon geworden. Kies algen om het voedsel terug te brengen.',
      _ => 'Kijk eerst naar de algen. Daar zit de sleutel van dit spel.',
    };
  }

  if (reef.solvedRound) {
    return 'Je zag het probleem en koos de tegenreactie. Dat is precies hoe balans terugkomt.';
  }

  return reef.incorrectReason;
}
