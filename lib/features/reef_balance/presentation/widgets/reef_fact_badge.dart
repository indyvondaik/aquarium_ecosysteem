import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_action.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:flutter/material.dart';

class ReefFactBadge extends StatelessWidget {
  const ReefFactBadge({required this.reef, required this.compact, super.key});

  final ReefState reef;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7E66B), Color(0xFFF7C85A)],
        ),
        border: Border.all(color: ReefColors.line, width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.all(compact ? 12 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 38 : 46,
            height: compact ? 38 : 46,
            decoration: BoxDecoration(
              color: ReefColors.paper.withValues(alpha: 0.88),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_rounded, color: ReefColors.ink),
          ),
          SizedBox(width: compact ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SUPERREGEL',
                  style: ReefTypography.condensed(size: compact ? 13 : 14),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    _mainRule(reef),
                    key: ValueKey(
                      '${reef.phase}-${reef.firstAction}-${reef.lastAction}',
                    ),
                    style: TextStyle(
                      color: ReefColors.ink,
                      fontSize: compact ? 13 : 15,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Krabben versnellen een verandering, maar lossen een algenprobleem niet alleen op.',
                  style: TextStyle(
                    color: ReefColors.ink.withValues(alpha: 0.84),
                    fontSize: compact ? 11 : 12,
                    height: 1.22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _mainRule(ReefState reef) {
  if (reef.isIntro) {
    return 'Gezond rif = genoeg algen voor de vissen, maar niet te veel.';
  }

  if (reef.isReaction) {
    return switch (reef.highlightedAction) {
      ReefAction.fish => 'Te veel algen? Voeg vissen toe.',
      ReefAction.algae => 'Te weinig algen? Voeg algen toe.',
      _ => 'Kijk eerst naar de algen. Daar zit de sleutel.',
    };
  }

  return reef.solvedRound
      ? 'Groei en consumptie zijn weer gelijk. Het rif ademt opnieuw.'
      : 'Zie je weinig algen? Voeg algen toe. Zie je veel algen? Voeg vissen toe.';
}
