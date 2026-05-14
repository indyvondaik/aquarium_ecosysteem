import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/info_aquarium/data/info_creature.dart';
import 'package:aquarium_ecosysteem/features/info_aquarium/presentation/widgets/creature_artwork.dart';
import 'package:flutter/material.dart';

class CreatureDetailScreen extends StatefulWidget {
  const CreatureDetailScreen({required this.creature, super.key});

  final InfoCreature creature;

  @override
  State<CreatureDetailScreen> createState() => _CreatureDetailScreenState();
}

class _CreatureDetailScreenState extends State<CreatureDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creature = widget.creature;
    final accent = creature.colors.primary;

    return Scaffold(
      backgroundColor: ReefColors.deepSea,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final phone = constraints.maxWidth < 480;
            final compact = constraints.maxWidth < 720;
            final wide = constraints.maxWidth >= 900;

            final illustration = _IllustrationCard(
              creature: creature,
              ambient: _ambient,
              accent: accent,
              compact: compact,
            );
            final info = _InfoColumn(
              creature: creature,
              accent: accent,
              phone: phone,
              compact: compact,
            );

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: phone ? 14 : 24,
                vertical: phone ? 12 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Tooltip(
                        message: 'Terug',
                        child: IconButton.filled(
                          onPressed: () => Navigator.of(context).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                ReefColors.paper.withValues(alpha: 0.94),
                            foregroundColor: ReefColors.navy,
                            side: const BorderSide(
                              color: ReefColors.navy,
                              width: 1.4,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          creature.category.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ReefTypography.condensed(
                            size: phone ? 16 : (compact ? 20 : 24),
                            color: ReefColors.paper,
                          ).copyWith(letterSpacing: 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 4, child: illustration),
                              const SizedBox(width: 24),
                              Expanded(flex: 5, child: info),
                            ],
                          )
                        : Column(
                            children: [
                              SizedBox(
                                height: phone ? 200 : 260,
                                child: illustration,
                              ),
                              const SizedBox(height: 16),
                              Expanded(child: info),
                            ],
                          ),
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

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard({
    required this.creature,
    required this.ambient,
    required this.accent,
    required this.compact,
  });

  final InfoCreature creature;
  final Animation<double> ambient;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F4A73),
            const Color(0xFF1C355E),
            const Color(0xFF4A253A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: EdgeInsets.all(compact ? 18 : 28),
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
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.creature,
    required this.accent,
    required this.phone,
    required this.compact,
  });

  final InfoCreature creature;
  final Color accent;
  final bool phone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleSize = phone ? 30.0 : (compact ? 44.0 : 60.0);
    final taglineSize = phone ? 15.0 : (compact ? 20.0 : 24.0);
    final bodySize = phone ? 15.0 : (compact ? 19.0 : 22.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 18 : 24,
        vertical: compact ? 18 : 22,
      ),
      decoration: BoxDecoration(
        color: ReefColors.paper.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ReefColors.navy, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: ReefColors.navy.withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                creature.dutchName.toUpperCase(),
                style: ReefTypography.display(
                  size: titleSize,
                  color: ReefColors.navy,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              creature.scientificName,
              style: TextStyle(
                fontFamily: ReefTypography.labelFamily,
                fontStyle: FontStyle.italic,
                color: ReefColors.purple,
                fontSize: phone ? 14.0 : (compact ? 18.0 : 21.0),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ReefColors.navy.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                creature.tagline,
                style: TextStyle(
                  fontFamily: ReefTypography.labelFamily,
                  color: ReefColors.ink,
                  fontSize: taglineSize,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              creature.description,
              style: TextStyle(
                fontFamily: ReefTypography.labelFamily,
                color: ReefColors.ink,
                fontSize: bodySize,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'WIST JE DAT?',
              style: ReefTypography.condensed(
                size: phone ? 14 : (compact ? 17 : 20),
                color: ReefColors.navy,
              ).copyWith(letterSpacing: 1.4),
            ),
            const SizedBox(height: 8),
            for (final fact in creature.funFacts) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 10),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ReefColors.navy,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        fact,
                        style: TextStyle(
                          fontFamily: ReefTypography.labelFamily,
                          color: ReefColors.ink,
                          fontSize: bodySize,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
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
    );
  }
}
