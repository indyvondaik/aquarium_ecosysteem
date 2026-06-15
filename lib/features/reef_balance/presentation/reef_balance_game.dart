import 'dart:async';
import 'dart:ui';

import 'package:aquarium_ecosysteem/app/app_screen.dart';
import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/application/reef_controller.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/application/tutorial_controller.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/ecosystem_choice_overlay.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_action_controls.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_scene_panel.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/tutorial_overlay.dart';
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
          final phone = constraints.maxWidth < 480;
          final compact = constraints.maxWidth < 720;
          final edge = phone ? 8.0 : (compact ? 10.0 : 18.0);
          final safe = MediaQuery.paddingOf(context);
          final resetWidth = phone ? 48.0 : (compact ? 56.0 : 64.0);
          // Vier knoppen rechtsboven (uitleg + mute + reset + home) —
          // reserveer ruimte.
          final controlsWidth = resetWidth * 4 + 24;
          final titleWidth =
              (constraints.maxWidth -
                      safe.left -
                      safe.right -
                      controlsWidth -
                      edge * 3)
                  .clamp(140.0, compact ? 320.0 : 540.0)
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
                child: _GameTitle(compact: compact, phone: phone),
              ),
              Positioned.fill(
                child: _CenterMessageOverlay(compact: compact, phone: phone),
              ),
              Positioned(
                top: safe.top + edge,
                right: safe.right + edge,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReefTutorialButton(
                      onPressed: () => ref
                          .read(ecosystemPhaseProvider.notifier)
                          .showTutorial(),
                    ),
                    const SizedBox(width: 8),
                    const ReefMuteButton(),
                    const SizedBox(width: 8),
                    ReefResetButton(onReset: controller.reset),
                    const SizedBox(width: 8),
                    ReefHomeButton(
                      onPressed: () {
                        controller.reset();
                        ref.read(ecosystemPhaseProvider.notifier).restart();
                        ref
                            .read(appScreenProvider.notifier)
                            .goTo(AppScreen.start);
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                left: safe.left + edge,
                right: safe.right + edge,
                bottom: safe.bottom + edge,
                child: ReefActionControls(
                  reef: reef,
                  onApply: controller.apply,
                  compact: compact,
                  phone: phone,
                ),
              ),
              const Positioned.fill(child: _EntryOverlay()),
            ],
          );
        },
      ),
    );
  }
}

/// Toont — afhankelijk van de fase — de keuze-popup (uitleg of starten), de
/// uitleg(video) of niets (tijdens het spelen). Ligt boven op het spel zodat
/// de spelstand eronder altijd bewaard blijft.
class _EntryOverlay extends ConsumerWidget {
  const _EntryOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(ecosystemPhaseProvider);
    return switch (phase) {
      EcosystemPhase.choosing => const EcosystemChoiceOverlay(),
      EcosystemPhase.tutorial => const TutorialOverlay(),
      EcosystemPhase.playing => const SizedBox.shrink(),
    };
  }
}

class _GameTitle extends StatelessWidget {
  const _GameTitle({required this.compact, required this.phone});

  final bool compact;
  final bool phone;

  @override
  Widget build(BuildContext context) {
    final titleSize = phone ? 26.0 : (compact ? 34.0 : 52.0);
    final subtitleSize = phone ? 10.0 : (compact ? 11.0 : 13.0);
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
              size: titleSize,
              color: ReefColors.paper,
            ),
          ),
        ),
        SizedBox(height: phone ? 4 : (compact ? 6 : 8)),
        Text(
          'Speur het rif af en houd alles in balans!',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: ReefTypography.labelFamily,
            color: ReefColors.paper,
            fontSize: subtitleSize,
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
  const _CenterMessageOverlay({required this.compact, required this.phone});

  final bool compact;
  final bool phone;

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
    final phone = widget.phone;
    final showOverlay = _visible && !reef.isAnimating;
    final headlineSize = phone ? 20.0 : (compact ? 24.0 : 36.0);
    final subtitleSize = phone ? 13.0 : (compact ? 15.0 : 19.0);
    final cardMaxWidth = phone ? 320.0 : (compact ? 420.0 : 620.0);
    final cardPaddingH = phone ? 16.0 : (compact ? 22.0 : 34.0);
    final cardPaddingV = phone ? 14.0 : (compact ? 18.0 : 26.0);
    final outerPaddingH = phone ? 12.0 : (compact ? 18.0 : 40.0);
    final innerGap = phone ? 10.0 : (compact ? 12.0 : 16.0);

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: showOverlay ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        child: Align(
          alignment: const Alignment(0, -0.12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: outerPaddingH),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardMaxWidth),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: cardPaddingH,
                      vertical: cardPaddingV,
                    ),
                    decoration: BoxDecoration(
                      color: ReefColors.paper.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: ReefColors.navy.withValues(alpha: 0.32),
                        width: 1.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ReefColors.navy.withValues(alpha: 0.28),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          reef.headline,
                          textAlign: TextAlign.center,
                          style: ReefTypography.condensed(
                            size: headlineSize,
                            color: ReefColors.navy,
                          ).copyWith(height: 1.1),
                        ),
                        SizedBox(height: innerGap),
                        Text(
                          _subtitleFor(reef),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: ReefTypography.labelFamily,
                            color: ReefColors.ink,
                            fontSize: subtitleSize,
                            height: 1.38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                        if (reef.phase == ReefRoundPhase.result) ...[
                          SizedBox(height: innerGap),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: phone ? 12 : 16,
                              vertical: phone ? 7 : 9,
                            ),
                            decoration: BoxDecoration(
                              color: ReefColors.navy.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.autorenew_rounded,
                                  size: subtitleSize + 2,
                                  color: ReefColors.navy,
                                ),
                                SizedBox(width: phone ? 6 : 8),
                                Flexible(
                                  child: Text(
                                    reef.autoResetLabel,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: ReefTypography.labelFamily,
                                      color: ReefColors.navy,
                                      fontSize: subtitleSize - 2,
                                      height: 1.25,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleFor(ReefState reef) {
    return switch (reef.phase) {
      ReefRoundPhase.intro =>
        'Jouw missie: kies een dier en verander het rif!',
      ReefRoundPhase.reaction =>
        'Welk dier redt het rif? Speur en kies!',
      ReefRoundPhase.result => reef.solvedRound
          ? 'Topspeurder! Het rif is gered!'
          : reef.incorrectReason,
    };
  }
}
