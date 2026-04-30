import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_action.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:flutter/material.dart';

typedef ReefActionCallback = void Function(ReefAction action);

class ReefActionControls extends StatelessWidget {
  const ReefActionControls({
    required this.reef,
    required this.onApply,
    required this.onReset,
    required this.compact,
    super.key,
  });

  final ReefState reef;
  final ReefActionCallback onApply;
  final VoidCallback onReset;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E3557), Color(0xFF194B6F)],
        ),
        border: Border.all(color: ReefColors.line, width: 2),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220A2540),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: EdgeInsets.all(compact ? 14 : 18),
      child: compact ? _CompactControls(this) : _WideControls(this),
    );
  }
}

class _WideControls extends StatelessWidget {
  const _WideControls(this.parent);

  final ReefActionControls parent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ControlsHeader(
          reef: parent.reef,
          onReset: parent.onReset,
          compact: false,
        ),
        const SizedBox(height: 16),
        for (final action in ReefAction.values) ...[
          _ActionButton(
            reef: parent.reef,
            action: action,
            selected: parent.reef.lastAction == action && !parent.reef.isIntro,
            suggested: _isSuggested(parent.reef, action),
            enabled: parent.reef.actionEnabled(action),
            onTap: () => parent.onApply(action),
            compact: false,
          ),
          if (action != ReefAction.values.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CompactControls extends StatelessWidget {
  const _CompactControls(this.parent);

  final ReefActionControls parent;

  @override
  Widget build(BuildContext context) {
    final actions = ReefAction.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlsHeader(
          reef: parent.reef,
          onReset: parent.onReset,
          compact: true,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var index = 0; index < actions.length; index++) ...[
              Expanded(
                child: _ActionButton(
                  reef: parent.reef,
                  action: actions[index],
                  selected:
                      parent.reef.lastAction == actions[index] &&
                      !parent.reef.isIntro,
                  suggested: _isSuggested(parent.reef, actions[index]),
                  enabled: parent.reef.actionEnabled(actions[index]),
                  onTap: () => parent.onApply(actions[index]),
                  compact: true,
                ),
              ),
              if (index != actions.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class _ControlsHeader extends StatelessWidget {
  const _ControlsHeader({
    required this.reef,
    required this.onReset,
    required this.compact,
  });

  final ReefState reef;
  final VoidCallback onReset;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeaderPill(
                    label: reef.stepLabel,
                    color: reef.isResult
                        ? reef.solvedRound
                              ? ReefColors.brightAlgae
                              : ReefColors.softCoral
                        : ReefColors.reefGold,
                    compact: compact,
                  ),
                  _HeaderPill(
                    label: compact
                        ? '${reef.choicesLeft} keuze${reef.choicesLeft == 1 ? '' : 's'}'
                        : 'Nog ${reef.choicesLeft} keuze${reef.choicesLeft == 1 ? '' : 's'}',
                    color: ReefColors.water,
                    compact: compact,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Nieuwe ronde',
              child: IconButton.filled(
                onPressed: onReset,
                style: IconButton.styleFrom(
                  backgroundColor: ReefColors.paper.withValues(alpha: 0.18),
                  foregroundColor: ReefColors.paper,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.restart_alt_rounded),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 12 : 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            reef.headline,
            key: ValueKey(reef.headline),
            style: ReefTypography.condensed(
              size: compact ? 18 : 21,
              color: ReefColors.paper,
            ),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            reef.prompt,
            key: ValueKey(reef.prompt),
            style: TextStyle(
              color: ReefColors.paper.withValues(alpha: 0.88),
              fontSize: compact ? 13 : 14,
              height: 1.25,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        if (reef.isResult) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: ReefColors.paper.withValues(alpha: 0.88),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reef.autoResetLabel,
                    style: TextStyle(
                      color: ReefColors.paper.withValues(alpha: 0.92),
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.label,
    required this.color,
    required this.compact,
  });

  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: ReefTypography.condensed(
          size: compact ? 11 : 12,
          color: ReefColors.ink,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  _ActionButton({
    required this.reef,
    required this.action,
    required this.selected,
    required this.suggested,
    required this.enabled,
    required this.onTap,
    required this.compact,
  });

  final ReefState reef;
  final ReefAction action;
  final bool selected;
  final bool suggested;
  final bool enabled;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final visual = _ActionVisual.from(action);
    final background = selected
        ? ReefColors.paper
        : Colors.white.withValues(alpha: suggested ? 0.22 : 0.12);
    final borderColor = selected
        ? visual.color
        : suggested
        ? visual.color.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.42);
    final textColor = selected ? ReefColors.ink : ReefColors.paper;
    final badgeText = _badgeText(reef, action, selected, suggested);

    return AnimatedScale(
      scale: selected ? 1.01 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Opacity(
        opacity: enabled || selected || suggested ? 1 : 0.6,
        child: Material(
          color: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: borderColor,
              width: selected || suggested ? 2 : 1.2,
            ),
          ),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              width: compact ? null : double.infinity,
              height: compact ? 104 : 106,
              child: Padding(
                padding: EdgeInsets.all(compact ? 10 : 14),
                child: compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _ActionIcon(
                                visual: visual,
                                selected: selected,
                                suggested: suggested,
                              ),
                              const Spacer(),
                              if (suggested)
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: visual.color,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else if (selected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: textColor.withValues(alpha: 0.92),
                                ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            action.buttonLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ReefTypography.condensed(
                              size: 12,
                              color: textColor,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          _ActionIcon(
                            visual: visual,
                            selected: selected,
                            suggested: suggested,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (badgeText != null) ...[
                                  _ChoiceBadge(
                                    text: badgeText,
                                    textColor: textColor,
                                    color: visual.color,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Text(
                                  action.buttonLabel.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ReefTypography.condensed(
                                    size: 15,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  visual.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.84),
                                    fontSize: 11,
                                    height: 1.1,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            enabled
                                ? Icons.chevron_right_rounded
                                : Icons.lock_outline_rounded,
                            color: textColor.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceBadge extends StatelessWidget {
  const _ChoiceBadge({
    required this.text,
    required this.textColor,
    required this.color,
  });

  final String text;
  final Color textColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: textColor == ReefColors.ink ? 0.18 : 0.24,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: ReefTypography.condensed(size: 11, color: textColor),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.visual,
    required this.selected,
    required this.suggested,
  });

  final _ActionVisual visual;
  final bool selected;
  final bool suggested;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: selected
            ? visual.color.withValues(alpha: 0.28)
            : Colors.white.withValues(alpha: suggested ? 0.18 : 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: visual.color, width: suggested ? 3.2 : 2.2),
        boxShadow: suggested
            ? [
                BoxShadow(
                  color: visual.color.withValues(alpha: 0.45),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        visual.icon,
        color: selected ? ReefColors.ink : ReefColors.paper,
        size: 28,
      ),
    );
  }
}

class _ActionVisual {
  const _ActionVisual({
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String subtitle;

  factory _ActionVisual.from(ReefAction action) {
    return switch (action) {
      ReefAction.algae => const _ActionVisual(
        icon: Icons.spa_rounded,
        color: ReefColors.brightAlgae,
        subtitle: 'Meer voedsel en groei',
      ),
      ReefAction.fish => const _ActionVisual(
        icon: Icons.set_meal_rounded,
        color: ReefColors.reefGold,
        subtitle: 'Eten extra algen weg',
      ),
      ReefAction.crab => const _ActionVisual(
        icon: Icons.cleaning_services_rounded,
        color: ReefColors.softCoral,
        subtitle: 'Ruimen de bodem op',
      ),
    };
  }
}

bool _isSuggested(ReefState reef, ReefAction action) {
  if (reef.isReaction) {
    return reef.highlightedAction == action;
  }

  if (reef.isResult && !reef.solvedRound) {
    return reef.idealCorrection == action;
  }

  return false;
}

String? _badgeText(
  ReefState reef,
  ReefAction action,
  bool selected,
  bool suggested,
) {
  if (reef.isIntro) {
    return 'Eerste keuze';
  }

  if (reef.isReaction && suggested) {
    return 'Goede hint';
  }

  if (reef.isResult && selected) {
    return reef.solvedRound ? 'Goed gedaan' : 'Jouw keuze';
  }

  if (reef.isResult && !reef.solvedRound && reef.idealCorrection == action) {
    return 'Beter idee';
  }

  if (selected) {
    return 'Gekozen';
  }

  return null;
}
