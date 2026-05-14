import 'package:flutter/painting.dart';

/// Manier waarop de [CreaturePainter] een organisme tekent. Elke variant
/// heeft een eigen teken-routine.
enum CreatureKind {
  seahorse,
  fingerLeatherCoral,
  cabbageLeatherCoral,
  buttonPolyps,
  coralDisc,
  foxface,
  copperband,
  yellowWrasse,
  hermitCrab,
}

/// Manier waarop een organisme subtiel beweegt op het info-scherm.
enum CreatureMotion {
  /// Lichte verticale bob — fijn voor zwevende dieren als het zeepaardje.
  bob,

  /// Heen-en-weer wuiven, voor koralen die op stroming reageren.
  sway,

  /// Korte trillingen + minimale verschuiving — voor vissen die nieuwsgierig
  /// blijven hangen.
  hover,

  /// Pulse: schaalt zacht op-en-af. Voor zachte koralen en koraalpoliepen.
  pulse,
}

class CreatureColors {
  const CreatureColors({
    required this.primary,
    required this.secondary,
    this.accent,
  });

  final Color primary;
  final Color secondary;
  final Color? accent;
}

class InfoCreature {
  const InfoCreature({
    required this.id,
    required this.dutchName,
    required this.scientificName,
    required this.category,
    required this.kind,
    required this.position,
    required this.motion,
    required this.size,
    required this.colors,
    required this.tagline,
    required this.description,
    required this.funFacts,
  });

  /// Unieke key — gebruikt voor hero-animaties en list-keys.
  final String id;

  final String dutchName;
  final String scientificName;

  /// Korte categorie-tag bovenaan het detail-scherm.
  final String category;

  final CreatureKind kind;

  /// Genormaliseerde positie (0..1) in het aquarium.
  final Offset position;

  final CreatureMotion motion;

  /// Genormaliseerde grootte (1.0 = standaard). Wordt vermenigvuldigd met
  /// de basis-pixelgrootte van de tile.
  final double size;

  final CreatureColors colors;

  /// Eenregelige aankondiging — verschijnt boven de beschrijving.
  final String tagline;

  /// Hoofdtekst op het detail-scherm.
  final String description;

  /// Korte feitjes als bullet-list.
  final List<String> funFacts;
}
