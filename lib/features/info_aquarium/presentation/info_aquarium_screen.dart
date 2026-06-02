import 'package:aquarium_ecosysteem/app/app_screen.dart';
import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/info_aquarium/data/creature_catalog.dart';
import 'package:aquarium_ecosysteem/features/info_aquarium/data/info_creature.dart';
import 'package:aquarium_ecosysteem/features/info_aquarium/presentation/creature_detail_screen.dart';
import 'package:aquarium_ecosysteem/features/info_aquarium/presentation/widgets/creature_artwork.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_state.dart';
import 'package:aquarium_ecosysteem/features/reef_balance/presentation/widgets/reef_scene_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfoAquariumScreen extends ConsumerStatefulWidget {
  const InfoAquariumScreen({super.key});

  @override
  ConsumerState<InfoAquariumScreen> createState() => _InfoAquariumScreenState();
}

class _InfoAquariumScreenState extends ConsumerState<InfoAquariumScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    // 8s loop is langzaam genoeg dat dieren rustig wiebelen — niet zo snel
    // dat ze moeilijk te raken zijn.
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  void _openDetail(InfoCreature creature) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreatureDetailScreen(creature: creature),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReefColors.deepSea,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final phone = constraints.maxWidth < 480;
          final compact = constraints.maxWidth < 720;
          final safe = MediaQuery.paddingOf(context);
          final edge = phone ? 8.0 : (compact ? 10.0 : 18.0);
          final size = Size(constraints.maxWidth, constraints.maxHeight);

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
              for (final creature in creatureCatalog)
                _CreatureTile(
                  creature: creature,
                  parentSize: size,
                  ambient: _ambient,
                  onTap: () => _openDetail(creature),
                ),
              Positioned(
                top: safe.top + edge,
                right: safe.right + edge,
                child: _BackToMenuButton(
                  onPressed: () => ref
                      .read(appScreenProvider.notifier)
                      .goTo(AppScreen.start),
                ),
              ),
              Positioned(
                top: safe.top + edge,
                left: safe.left + edge,
                right: safe.right + edge + 64,
                child: _ScreenHeader(phone: phone, compact: compact),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BackToMenuButton extends StatelessWidget {
  const _BackToMenuButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Naar startmenu',
      child: IconButton.filled(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: ReefColors.paper.withValues(alpha: 0.94),
          foregroundColor: ReefColors.navy,
          side: const BorderSide(color: ReefColors.navy, width: 1.4),
          visualDensity: VisualDensity.compact,
        ),
        icon: const Icon(Icons.home_rounded),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.phone, required this.compact});

  final bool phone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleSize = phone ? 22.0 : (compact ? 30.0 : 44.0);
    final subtitleSize = phone ? 11.0 : (compact ? 12.0 : 14.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'WIE LEEFT HIER?',
            style: ReefTypography.display(
              size: titleSize,
              color: ReefColors.paper,
            ),
          ),
        ),
        SizedBox(height: phone ? 4 : 6),
        Text(
          'Tik op een dier of koraal om er meer over te leren.',
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

class _CreatureTile extends StatelessWidget {
  const _CreatureTile({
    required this.creature,
    required this.parentSize,
    required this.ambient,
    required this.onTap,
  });

  final InfoCreature creature;
  final Size parentSize;
  final Animation<double> ambient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Basis-tegelgrootte schaalt mee met het schermformaat.
    final shortest =
        parentSize.shortestSide.clamp(280.0, 1200.0).toDouble();
    final base = shortest * 0.24;
    final width = base * creature.size;
    final height = base * creature.size;

    final left = (parentSize.width * creature.position.dx - width / 2)
        .clamp(8.0, parentSize.width - width - 8.0)
        .toDouble();
    final top = (parentSize.height * creature.position.dy - height / 2)
        .clamp(8.0, parentSize.height - height - 8.0)
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Semantics(
        button: true,
        label: '${creature.dutchName}. Tik voor meer informatie.',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: AnimatedBuilder(
              animation: ambient,
              builder: (context, _) {
                return CreatureArtwork(
                  creature: creature,
                  time: ambient.value,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
