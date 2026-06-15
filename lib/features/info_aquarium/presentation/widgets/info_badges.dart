import 'package:aquarium_ecosysteem/app/theme/reef_theme.dart';
import 'package:aquarium_ecosysteem/features/info_aquarium/data/info_creature.dart';
import 'package:flutter/material.dart';

/// De bekende IUCN Rode Lijst-statusbalk (de "IUCN-map"): van Niet bedreigd
/// (groen) tot Uitgestorven (zwart). De huidige status wordt gemarkeerd met
/// een driehoekje en een dikkere rand. Statussen die niet op de schaal staan
/// (Niet beoordeeld / Onvoldoende gegevens) tonen geen markering.
class IucnScaleBar extends StatelessWidget {
  const IucnScaleBar({required this.status, this.barHeight = 20, super.key});

  final IucnStatus status;
  final double barHeight;

  /// De zeven categorieën op de officiële schaal, van laag naar hoog risico.
  static const _scale = <IucnStatus>[
    IucnStatus.leastConcern,
    IucnStatus.nearThreatened,
    IucnStatus.vulnerable,
    IucnStatus.endangered,
    IucnStatus.criticallyEndangered,
    IucnStatus.extinctInWild,
    IucnStatus.extinct,
  ];

  static Color _readableOn(Color background) {
    return background.computeLuminance() > 0.5
        ? const Color(0xFF1C355E)
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _scale.indexOf(status);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Markeringsrij — driehoekje boven de actieve categorie.
        SizedBox(
          height: 9,
          child: Row(
            children: [
              for (var i = 0; i < _scale.length; i++)
                Expanded(
                  child: Center(
                    child: i == activeIndex
                        ? CustomPaint(
                            size: const Size(12, 8),
                            painter: _DownTriangle(ReefColors.navy),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        // De gekleurde balk met de codes.
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ReefColors.navy, width: 1.2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: barHeight,
              child: Row(
                children: [
                  for (var i = 0; i < _scale.length; i++)
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _scale[i].color,
                          border: i == activeIndex
                              ? Border.all(color: ReefColors.navy, width: 2.2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _scale[i].code,
                            style: TextStyle(
                              fontFamily: ReefTypography.labelFamily,
                              fontSize: 11,
                              height: 1,
                              fontWeight: i == activeIndex
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: _readableOn(_scale[i].color),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DownTriangle extends CustomPainter {
  _DownTriangle(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DownTriangle oldDelegate) => oldDelegate.color != color;
}

/// Compacte badge die aangeeft dat de soort in een EAZA Ex-situ Programme
/// (EEP) zit. Geen officieel logo-asset nodig — een nette nagebouwde badge.
class EepBadge extends StatelessWidget {
  const EepBadge({super.key});

  static const _green = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _green, width: 1.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Embleem-cirkeltje.
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 7),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EEP',
                style: TextStyle(
                  fontFamily: ReefTypography.labelFamily,
                  fontSize: 15,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: _green,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'EAZA-fokprogramma',
                style: TextStyle(
                  fontFamily: ReefTypography.labelFamily,
                  fontSize: 9,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: ReefColors.navy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Het paarse bolletje (#624B78) met wit "wist je dat?"-weetje dat midden op
/// de foto/illustratie van het dier komt te liggen.
class FactBubble extends StatelessWidget {
  const FactBubble({required this.fact, required this.diameter, super.key});

  final String fact;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ReefColors.purple, // #624B78
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(diameter * 0.16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Wist je dat?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: ReefTypography.labelFamily,
                fontSize: diameter * 0.092,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            SizedBox(height: diameter * 0.03),
            Flexible(
              child: Text(
                fact,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: ReefTypography.labelFamily,
                  fontSize: diameter * 0.088,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
