import 'dart:async';

import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_action.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_life_icon.dart';
import 'package:flutter/material.dart';

typedef ReefActionCallback = void Function(ReefAction action);

class ReefActionControls extends StatelessWidget {
  const ReefActionControls({
    required this.reef,
    required this.onApply,
    required this.compact,
    super.key,
  });

  final ReefState reef;
  final ReefActionCallback onApply;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final action in ReefAction.values) ...[
          _ActionButton(
            reef: reef,
            action: action,
            selected: reef.lastAction == action && !reef.isIntro,
            suggested: _isSuggested(reef, action),
            enabled: reef.actionEnabled(action),
            onTap: () => onApply(action),
            compact: compact,
          ),
          if (action != ReefAction.values.last)
            SizedBox(width: compact ? 8 : 12),
        ],
      ],
    );
  }
}

class ReefResetButton extends StatelessWidget {
  const ReefResetButton({required this.onReset, super.key});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Nieuw spel',
      child: IconButton.filled(
        onPressed: onReset,
        style: IconButton.styleFrom(
          backgroundColor: ReefColors.paper.withValues(alpha: 0.94),
          foregroundColor: ReefColors.navy,
          side: const BorderSide(color: ReefColors.navy, width: 1.4),
          visualDensity: VisualDensity.compact,
        ),
        icon: const Icon(Icons.restart_alt_rounded),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
    final textColor = selected ? ReefColors.navy : ReefColors.paper;
    final iconColor = selected ? ReefColors.purple : ReefColors.paper;
    final tileWidth = compact ? 168.0 : 220.0;
    final tileHeight = compact ? 76.0 : 88.0;

    return _DelayedHintBlink(
      active: suggested && enabled && !selected,
      resetKey: '${reef.eventId}-${reef.phase}-$action',
      builder: (context, blink) {
        final background = selected
            ? ReefColors.paper
            : suggested
            ? Color.lerp(ReefColors.purple, ReefColors.paper, blink * 0.26)!
            : ReefColors.navy.withValues(alpha: 0.9);
        final borderColor = selected
            ? ReefColors.paper
            : suggested
            ? Color.lerp(ReefColors.paper, ReefColors.reefGold, blink)!
            : ReefColors.paper.withValues(alpha: 0.64);

        return AnimatedScale(
          scale: selected
              ? 1.02
              : suggested
              ? 1 + blink * 0.035
              : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          child: Opacity(
            opacity: enabled || selected || suggested ? 1 : 0.62,
            child: Material(
              color: background,
              shadowColor: ReefColors.reefGold.withValues(alpha: blink * 0.5),
              elevation: suggested ? blink * 8 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: borderColor,
                  width: selected || suggested ? 2 + blink * 1.3 : 1.2,
                ),
              ),
              child: InkWell(
                onTap: enabled ? onTap : null,
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: tileWidth,
                  height: tileHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 10 : 14,
                      vertical: compact ? 8 : 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ActionIcon(
                          visual: visual,
                          color: iconColor,
                          selected: selected,
                          suggested: suggested,
                          hintValue: blink,
                          compact: compact,
                        ),
                        SizedBox(width: compact ? 10 : 12),
                        Expanded(
                          child: Text(
                            action.buttonLabel.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ReefTypography.condensed(
                              size: compact ? 13 : 15,
                              color: textColor,
                            ),
                          ),
                        ),
                        _StateMark(
                          selected: selected,
                          suggested: suggested,
                          color: textColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DelayedHintBlink extends StatefulWidget {
  const _DelayedHintBlink({
    required this.active,
    required this.resetKey,
    required this.builder,
  });

  final bool active;
  final String resetKey;
  final Widget Function(BuildContext context, double value) builder;

  @override
  State<_DelayedHintBlink> createState() => _DelayedHintBlinkState();
}

class _DelayedHintBlinkState extends State<_DelayedHintBlink>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _delayTimer;
  bool _armed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
      reverseDuration: const Duration(milliseconds: 380),
    );
    _syncAnimation(reset: true);
  }

  @override
  void didUpdateWidget(covariant _DelayedHintBlink oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active ||
        oldWidget.resetKey != widget.resetKey) {
      _syncAnimation(reset: true);
    }
  }

  void _syncAnimation({required bool reset}) {
    _delayTimer?.cancel();

    if (!widget.active) {
      _armed = false;
      _controller
        ..stop()
        ..value = 0;
      return;
    }

    if (reset) {
      _armed = false;
      _controller
        ..stop()
        ..value = 0;
    }

    _delayTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted || !widget.active) {
        return;
      }

      setState(() {
        _armed = true;
      });
      _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = _armed
            ? Curves.easeInOut.transform(_controller.value)
            : 0.0;
        return widget.builder(context, value);
      },
    );
  }
}

class _StateMark extends StatelessWidget {
  const _StateMark({
    required this.selected,
    required this.suggested,
    required this.color,
  });

  final bool selected;
  final bool suggested;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Icon(Icons.check_circle_rounded, size: 18, color: color);
    }

    if (suggested) {
      return Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          color: ReefColors.paper,
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.62), width: 1),
        ),
      );
    }

    return Icon(
      Icons.chevron_right_rounded,
      color: color.withValues(alpha: 0.78),
      size: 20,
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.visual,
    required this.color,
    required this.selected,
    required this.suggested,
    required this.hintValue,
    required this.compact,
  });

  final _ActionVisual visual;
  final Color color;
  final bool selected;
  final bool suggested;
  final double hintValue;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 34.0 : 46.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected
            ? ReefColors.purple.withValues(alpha: 0.14)
            : Colors.white.withValues(
                alpha: suggested ? 0.18 + hintValue * 0.16 : 0.1,
              ),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? ReefColors.purple
              : Color.lerp(ReefColors.paper, ReefColors.reefGold, hintValue)!,
          width: suggested ? 2.6 + hintValue : 1.7,
        ),
      ),
      child: Center(
        child: ReefLifeIcon(
          type: visual.type,
          color: color,
          accentColor: color.withValues(alpha: 0.56),
          size: compact ? 22 : 29,
          semanticLabel: visual.semanticLabel,
        ),
      ),
    );
  }
}

class _ActionVisual {
  const _ActionVisual({required this.type, required this.semanticLabel});

  final ReefLifeIconType type;
  final String semanticLabel;

  factory _ActionVisual.from(ReefAction action) {
    return switch (action) {
      ReefAction.algae => const _ActionVisual(
        type: ReefLifeIconType.algae,
        semanticLabel: 'Alg',
      ),
      ReefAction.fish => const _ActionVisual(
        type: ReefLifeIconType.fish,
        semanticLabel: 'Vis',
      ),
      ReefAction.crab => const _ActionVisual(
        type: ReefLifeIconType.crab,
        semanticLabel: 'Krab',
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
