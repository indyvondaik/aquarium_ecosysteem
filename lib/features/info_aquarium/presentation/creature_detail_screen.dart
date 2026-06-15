import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/info_aquarium/data/info_creature.dart';
import 'package:aquarium_ecosysteem/features/info_aquarium/presentation/widgets/creature_artwork.dart';
import 'package:aquarium_ecosysteem/features/info_aquarium/presentation/widgets/info_badges.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
            final showVideo = creature.showVideo;
            final video =
                showVideo ? _VideoSlot(creature: creature, accent: accent) : null;

            // Foto + (optioneel) video met het paarse weetje-bolletje dat
            // over de naad tussen beide containers zweeft. [vertical] true =>
            // foto boven, video onder (brede layout); anders naast elkaar.
            // Zonder video vult de foto de hele ruimte en zweeft het bolletje
            // rechtsonder over de foto.
            Widget mediaGroup({required bool vertical}) {
              const gap = 14.0;
              final Widget group;
              if (!showVideo) {
                group = illustration;
              } else if (vertical) {
                group = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: illustration),
                    const SizedBox(height: gap),
                    Expanded(flex: 2, child: video!),
                  ],
                );
              } else {
                group = Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: illustration),
                    const SizedBox(width: gap),
                    Expanded(child: video!),
                  ],
                );
              }

              return LayoutBuilder(
                builder: (context, c) {
                  final d = (c.biggest.shortestSide * 0.42).clamp(84.0, 176.0);
                  // Aan de rechterkant van de containers, op de naad tussen
                  // foto en video — of rechtsonder als er geen video is.
                  final double cx, cy;
                  cx = c.maxWidth - d / 2 - 8;
                  if (!showVideo) {
                    cy = c.maxHeight - d / 2 - 10;
                  } else if (vertical) {
                    final illH = (c.maxHeight - gap) * 3 / 5;
                    cy = illH + gap / 2;
                  } else {
                    cy = c.maxHeight / 2;
                  }
                  return Stack(
                    children: [
                      Positioned.fill(child: group),
                      Positioned(
                        left: cx - d / 2,
                        top: cy - d / 2,
                        width: d,
                        height: d,
                        child: FactBubble(
                          fact: creature.bubbleFact,
                          diameter: d,
                        ),
                      ),
                    ],
                  );
                },
              );
            }

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
                              Expanded(
                                flex: 5,
                                child: mediaGroup(vertical: true),
                              ),
                              const SizedBox(width: 24),
                              Expanded(flex: 6, child: info),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                flex: 5,
                                child: mediaGroup(vertical: false),
                              ),
                              const SizedBox(height: 14),
                              Expanded(flex: 6, child: info),
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
        child: creature.photoAsset != null
            // Echte foto: cover vult de hele container; het dier staat
            // gecentreerd in beeld zodat het goed zichtbaar blijft.
            ? Image.asset(
                creature.photoAsset!,
                fit: creature.photoFit,
                alignment: creature.photoAlignment,
                width: double.infinity,
                height: double.infinity,
              )
            : Padding(
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
    final titleSize = phone ? 26.0 : (compact ? 38.0 : 50.0);
    final bodySize = phone ? 13.0 : (compact ? 15.0 : 17.0);
    final descSize = phone ? 15.0 : (compact ? 18.0 : 22.0);
    final labelSize = phone ? 11.0 : (compact ? 12.0 : 13.0);

    // De vaste volgorde van de steekkaart, exact zoals gevraagd:
    // leefgebied, voeding, gewicht, leeftijd, jongeren/eieren, draag-/broedtijd.
    final stats = <_Stat>[
      _Stat(Icons.public_rounded, 'Leefgebied', creature.habitat),
      _Stat(Icons.restaurant_rounded, 'Voeding', creature.diet),
      _Stat(Icons.monitor_weight_rounded, 'Gewicht', creature.weight),
      _Stat(Icons.hourglass_bottom_rounded, 'Leeftijd', creature.lifespan),
      _Stat(Icons.egg_alt_rounded, 'Jongeren / eieren', creature.offspring),
      _Stat(Icons.event_rounded, 'Draag- / broedtijd', creature.breedingTime),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 22,
        vertical: compact ? 16 : 20,
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
      // Bovenste inhoud schaalt mee (geen scroll); de IUCN-balk wordt
      // onderaan de witte container vastgezet met ruimte ertussen.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: c.maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(height: 6),
                        Text(
                          creature.scientificName,
                          style: TextStyle(
                            fontFamily: ReefTypography.labelFamily,
                            fontStyle: FontStyle.italic,
                            color: ReefColors.purple,
                            fontSize: phone ? 13.0 : (compact ? 16.0 : 19.0),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Hoofdtekst — staat boven de steekkaart met kopjes.
                        Text(
                          creature.description,
                          style: TextStyle(
                            fontFamily: ReefTypography.labelFamily,
                            color: ReefColors.ink,
                            fontSize: descSize,
                            height: 1.45,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Steekkaart in twee kolommen, in de gevraagde volgorde.
                        _StatGrid(
                          stats: stats,
                          columns: phone ? 1 : 2,
                          labelSize: labelSize,
                          valueSize: bodySize,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Beschermingsstatus onderaan: IUCN-map + status + EEP-logo.
          _ProtectionSection(
            creature: creature,
            labelSize: labelSize,
            valueSize: bodySize,
          ),
        ],
      ),
    );
  }
}

/// Eén regel van de steekkaart: icoon, label en waarde.
class _Stat {
  const _Stat(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

/// Toont de steekkaart in een net raster van 1 of 2 kolommen.
class _StatGrid extends StatelessWidget {
  const _StatGrid({
    required this.stats,
    required this.columns,
    required this.labelSize,
    required this.valueSize,
  });

  final List<_Stat> stats;
  final int columns;
  final double labelSize;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < stats.length; i += columns) {
      final cells = <Widget>[];
      for (var j = 0; j < columns; j++) {
        final index = i + j;
        if (j > 0) cells.add(const SizedBox(width: 16));
        cells.add(
          Expanded(
            child: index < stats.length
                ? _StatTile(
                    stat: stats[index],
                    labelSize: labelSize,
                    valueSize: valueSize,
                  )
                : const SizedBox.shrink(),
          ),
        );
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cells,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.stat,
    required this.labelSize,
    required this.valueSize,
  });

  final _Stat stat;
  final double labelSize;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1, right: 8),
          child: Icon(stat.icon, size: valueSize + 5, color: ReefColors.navy),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stat.label.toUpperCase(),
                style: TextStyle(
                  fontFamily: ReefTypography.labelFamily,
                  color: ReefColors.navy,
                  fontSize: valueSize + 2,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stat.value,
                style: TextStyle(
                  fontFamily: ReefTypography.labelFamily,
                  color: ReefColors.navy,
                  fontSize: valueSize,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Beschermingsblok onderaan: IUCN-status, de IUCN-statusbalk ("map") en —
/// indien van toepassing — het EEP-logo.
class _ProtectionSection extends StatelessWidget {
  const _ProtectionSection({
    required this.creature,
    required this.labelSize,
    required this.valueSize,
  });

  final InfoCreature creature;
  final double labelSize;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'IUCN-STATUS',
              style: TextStyle(
                fontFamily: ReefTypography.labelFamily,
                color: ReefColors.navy,
                fontSize: labelSize,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 10),
            _IucnStatusChip(
              status: creature.iucnStatus,
              fontSize: valueSize,
            ),
            const Spacer(),
            if (creature.inEep) const EepBadge(),
          ],
        ),
        const SizedBox(height: 8),
        IucnScaleBar(status: creature.iucnStatus),
      ],
    );
  }
}

class _IucnStatusChip extends StatelessWidget {
  const _IucnStatusChip({required this.status, required this.fontSize});

  final IucnStatus status;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final readable = status.color.computeLuminance() > 0.5
        ? ReefColors.navy
        : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ReefColors.navy, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.code,
            style: TextStyle(
              fontFamily: ReefTypography.labelFamily,
              color: readable,
              fontSize: fontSize + 1,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.labelNl,
            style: TextStyle(
              fontFamily: ReefTypography.labelFamily,
              color: readable,
              fontSize: fontSize,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Toont de video over het dier of koraal als [InfoCreature.videoAsset] is
/// ingevuld; anders een nette "Video volgt binnenkort"-placeholder. Tik om
/// af te spelen of te pauzeren; de video loopt door.
class _VideoSlot extends StatefulWidget {
  const _VideoSlot({required this.creature, required this.accent});

  final InfoCreature creature;
  final Color accent;

  @override
  State<_VideoSlot> createState() => _VideoSlotState();
}

class _VideoSlotState extends State<_VideoSlot> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final asset = widget.creature.videoAsset;
    if (asset != null) {
      final controller = VideoPlayerController.asset(asset);
      _controller = controller;
      controller
        ..setLooping(true)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() => _ready = true);
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null || !_ready) return;
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F4A73),
                Color(0xFF1C355E),
                Color(0xFF4A253A),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.accent.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final controller = _controller;

    // Geen video toegewezen: placeholder.
    if (controller == null) return _placeholder();

    // Video laadt nog.
    if (!_ready) {
      return const Center(
        child: SizedBox(
          width: 42,
          height: 42,
          child: CircularProgressIndicator(
            color: ReefColors.paper,
            strokeWidth: 3,
          ),
        ),
      );
    }

    // Afspeelbare video met tik-om-af-te-spelen en een play-knop overlay.
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
          AnimatedOpacity(
            opacity: controller.value.isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.22),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ReefColors.paper.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                    border: Border.all(color: ReefColors.navy, width: 2),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 38,
                    color: ReefColors.navy,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ReefColors.paper.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  border: Border.all(color: ReefColors.navy, width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 38,
                  color: ReefColors.navy,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Video volgt binnenkort',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: ReefTypography.labelFamily,
                  color: ReefColors.paper,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
