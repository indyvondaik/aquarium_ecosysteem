import 'dart:math' as math;
import 'dart:ui';

import 'package:aquarium_ecosysteem/app/app_screen.dart';
import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/application/reef_controller.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/application/tutorial_controller.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_action_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keuze-popup die verschijnt zodra het ecosysteem-spel geopend wordt: eerst
/// de uitlegvideo kijken of meteen starten.
class EcosystemChoiceOverlay extends ConsumerWidget {
  const EcosystemChoiceOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.read(ecosystemPhaseProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final phone = constraints.maxWidth < 480;
        final compact = constraints.maxWidth < 720;
        final cardWidth = phone
            ? constraints.maxWidth - 16
            : compact
                ? math.min(constraints.maxWidth - 32, 520.0)
                : 560.0;
        final cardPadding = phone ? 18.0 : (compact ? 24.0 : 32.0);
        final titleSize = phone ? 26.0 : (compact ? 32.0 : 42.0);
        final bodySize = phone ? 14.0 : (compact ? 16.0 : 19.0);

        return Stack(
          children: [
            // Scrim — vangt taps zodat het spel eronder niet reageert.
            Positioned.fill(
              child: ColoredBox(
                color: ReefColors.navy.withValues(alpha: 0.55),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardWidth),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: ReefColors.paper.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: ReefColors.navy.withValues(alpha: 0.4),
                          width: 1.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ReefColors.navy.withValues(alpha: 0.32),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'ECOSYSTEEM SPEL',
                            textAlign: TextAlign.center,
                            style: ReefTypography.display(
                              size: titleSize,
                              color: ReefColors.navy,
                            ),
                          ),
                          SizedBox(height: phone ? 8 : 12),
                          Text(
                            'Wil je eerst de uitlegvideo kijken of gelijk '
                            'starten?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: ReefTypography.labelFamily,
                              color: ReefColors.ink,
                              fontSize: bodySize,
                              fontWeight: FontWeight.w800,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: phone ? 18 : 26),
                          _ChoiceButtons(
                            compact: compact,
                            phone: phone,
                            onTutorial: phase.showTutorial,
                            onStart: phase.play,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top +
                  (phone ? 8.0 : (compact ? 10.0 : 18.0)),
              right: MediaQuery.paddingOf(context).right +
                  (phone ? 8.0 : (compact ? 10.0 : 18.0)),
              child: ReefHomeButton(
                onPressed: () {
                  ref.read(reefControllerProvider.notifier).reset();
                  ref.read(ecosystemPhaseProvider.notifier).restart();
                  ref.read(appScreenProvider.notifier).goTo(AppScreen.start);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChoiceButtons extends StatelessWidget {
  const _ChoiceButtons({
    required this.compact,
    required this.phone,
    required this.onTutorial,
    required this.onStart,
  });

  final bool compact;
  final bool phone;
  final VoidCallback onTutorial;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final tutorialButton = _ChoiceButton(
      label: 'Uitlegvideo kijken',
      icon: Icons.ondemand_video_rounded,
      primary: false,
      compact: compact,
      onPressed: onTutorial,
    );
    final startButton = _ChoiceButton(
      label: 'Start',
      icon: Icons.play_arrow_rounded,
      primary: true,
      compact: compact,
      onPressed: onStart,
    );

    if (phone) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tutorialButton,
          const SizedBox(height: 12),
          startButton,
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: tutorialButton),
        const SizedBox(width: 14),
        Flexible(child: startButton),
      ],
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.compact,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool primary;
  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = primary ? ReefColors.paper : ReefColors.navy;
    final background =
        primary ? ReefColors.navy : ReefColors.paper.withValues(alpha: 0.9);

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ReefColors.navy, width: 1.6),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 18 : 24,
            vertical: compact ? 13 : 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground, size: compact ? 20 : 24),
              SizedBox(width: compact ? 8 : 10),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ReefTypography.condensed(
                    size: compact ? 14 : 17,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
