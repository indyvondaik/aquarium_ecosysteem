import 'dart:async';

import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/application/reef_controller.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_action_controls.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_scene_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReefBalanceGame extends ConsumerWidget {
  const ReefBalanceGame({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reef = ref.watch(reefControllerProvider);
    final controller = ref.read(reefControllerProvider.notifier);

    return Scaffold(
      backgroundColor: ReefColors.navy,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final edge = compact ? 10.0 : 18.0;
          final safe = MediaQuery.paddingOf(context);
          final resetWidth = compact ? 56.0 : 64.0;
          final titleWidth =
              (constraints.maxWidth -
                      safe.left -
                      safe.right -
                      resetWidth -
                      edge * 3)
                  .clamp(180.0, compact ? 320.0 : 540.0)
                  .toDouble();

          return Stack(
            children: [
              Positioned.fill(
                child: ReefScenePanel(
                  reef: reef,
                  onTap: controller.rippleAt,
                  compact: compact,
                ),
              ),
              Positioned(
                top: safe.top + edge,
                left: safe.left + edge,
                width: titleWidth,
                child: _GameTitle(compact: compact),
              ),
              Positioned.fill(
                child: _CenterMessageOverlay(compact: compact),
              ),
              Positioned(
                top: safe.top + edge,
                right: safe.right + edge,
                child: ReefResetButton(onReset: controller.reset),
              ),
              Positioned(
                left: safe.left + edge,
                right: safe.right + edge,
                bottom: safe.bottom + edge,
                child: ReefActionControls(
                  reef: reef,
                  onApply: controller.apply,
                  compact: compact,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GameTitle extends StatelessWidget {
  const _GameTitle({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'RIF IN BALANS',
            style: ReefTypography.display(
              size: compact ? 34 : 52,
              color: ReefColors.paper,
            ),
          ),
        ),
        SizedBox(height: compact ? 6 : 8),
        Text(
          'Tijd voor een rifavontuur! Algen maken voedsel, vissen smullen '
          'ervan en krabben houden de bodem schoon.',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: ReefColors.paper,
            fontSize: compact ? 11 : 13,
            height: 1.28,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            shadows: [
              Shadow(
                color: ReefColors.navy.withValues(alpha: 0.7),
                offset: const Offset(0, 1.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CenterMessageOverlay extends ConsumerStatefulWidget {
  const _CenterMessageOverlay({required this.compact});

  final bool compact;

  @override
  ConsumerState<_CenterMessageOverlay> createState() =>
      _CenterMessageOverlayState();
}

class _CenterMessageOverlayState extends ConsumerState<_CenterMessageOverlay> {
  static const Duration _reactionAutoHide = Duration(milliseconds: 4200);

  Timer? _hideTimer;
  bool _visible = true;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onAnimationFinished(ReefState reef) {
    _hideTimer?.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      _visible = true;
    });
    if (reef.phase == ReefRoundPhase.reaction) {
      _hideTimer = Timer(_reactionAutoHide, () {
        if (!mounted) {
          return;
        }
        setState(() {
          _visible = false;
        });
      });
    }
  }

  void _onResetToIntro() {
    _hideTimer?.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      _visible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ReefState>(reefControllerProvider, (previous, next) {
      if (previous == null) {
        return;
      }
      if (previous.isAnimating && !next.isAnimating) {
        _onAnimationFinished(next);
      }
      if (previous.phase != ReefRoundPhase.intro &&
          next.phase == ReefRoundPhase.intro) {
        _onResetToIntro();
      }
    });

    final reef = ref.watch(reefControllerProvider);
    final compact = widget.compact;
    final showOverlay = _visible && !reef.isAnimating;

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: showOverlay ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  reef.headline,
                  textAlign: TextAlign.center,
                  style:
                      ReefTypography.condensed(
                        size: compact ? 22 : 32,
                        color: ReefColors.paper,
                      ).copyWith(
                        height: 1.05,
                        shadows: [
                          Shadow(
                            color: ReefColors.navy.withValues(alpha: 0.85),
                            offset: const Offset(0, 2),
                            blurRadius: 9,
                          ),
                        ],
                      ),
                ),
                SizedBox(height: compact ? 10 : 14),
                Text(
                  _subtitleFor(reef),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ReefColors.paper,
                    fontSize: compact ? 13 : 17,
                    height: 1.28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    shadows: [
                      Shadow(
                        color: ReefColors.navy.withValues(alpha: 0.78),
                        offset: const Offset(0, 1.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleFor(ReefState reef) {
    return switch (reef.phase) {
      ReefRoundPhase.intro =>
        'Pak je backpack en speur het rif af! Verstoor het met één keuze. '
            'Krijg jij het rif daarna weer in balans?',
      ReefRoundPhase.reaction =>
        '${reef.observationDetail} Wat doe jij om het rif te redden?',
      ReefRoundPhase.result => reef.solvedRound
          ? 'Klaar voor een nieuw avontuur? Het volgende rif wacht op je!'
          : '${reef.incorrectReason} Een nieuw rifavontuur staat klaar!',
    };
  }
}
