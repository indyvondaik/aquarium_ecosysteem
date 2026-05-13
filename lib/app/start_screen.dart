import 'package:aquarium_ecosysteem/app/app_screen.dart';
import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_scene_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ReefColors.deepSea,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final phone = constraints.maxWidth < 480;
          final compact = constraints.maxWidth < 720;
          final titleSize = phone ? 36.0 : (compact ? 52.0 : 78.0);
          final subtitleSize = phone ? 12.0 : (compact ? 14.0 : 17.0);
          final buttonWidth = phone
              ? constraints.maxWidth - 48
              : (compact ? 320.0 : 380.0);

          return Stack(
            children: [
              Positioned.fill(
                child: ReefScenePanel(
                  reef: ReefState.initial,
                  onTap: (_, _) {},
                  compact: compact,
                  decorative: true,
                ),
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x661C355E), Color(0x00000000)],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: phone ? 16 : 32,
                    vertical: phone ? 18 : 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'ONTDEK HET AQUARIUM!',
                          textAlign: TextAlign.center,
                          style: ReefTypography.display(
                            size: titleSize,
                            color: ReefColors.paper,
                          ),
                        ),
                      ),
                      SizedBox(height: phone ? 6 : 10),
                      Text(
                        'Kies wat je wil gaan doen!',
                        textAlign: TextAlign.center,
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
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _MenuButton(
                                width: buttonWidth,
                                icon: Icons.menu_book_rounded,
                                label: 'INFORMATIE',
                                color: ReefColors.water,
                                onTap: () {
                                  // Komt later — gebruiker voegt scherm toe.
                                },
                              ),
                              SizedBox(height: phone ? 12 : 18),
                              _MenuButton(
                                width: buttonWidth,
                                icon: Icons.quiz_rounded,
                                label: 'QUIZ',
                                color: ReefColors.reefGold,
                                onTap: () {
                                  // Komt later — gebruiker voegt scherm toe.
                                },
                              ),
                              SizedBox(height: phone ? 12 : 18),
                              _MenuButton(
                                width: buttonWidth,
                                icon: Icons.waves_rounded,
                                label: 'ECOSYSTEEM SPEL',
                                color: ReefColors.brightAlgae,
                                onTap: () => ref
                                    .read(appScreenProvider.notifier)
                                    .goTo(AppScreen.ecosystem),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.width,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ReefColors.paper,
      elevation: 4,
      shadowColor: ReefColors.navy.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: ReefColors.navy, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: width,
          height: 76,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ReefColors.navy.withValues(alpha: 0.32),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(icon, size: 30, color: ReefColors.navy),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ReefTypography.condensed(
                      size: 22,
                      color: ReefColors.navy,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 32,
                  color: ReefColors.navy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
