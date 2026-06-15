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
  cleanerShrimp,
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

/// IUCN Rode Lijst-status. Bevat de officiële code, een Nederlandse naam en
/// de officiële IUCN-kleur. De [IucnScaleBar] gebruikt deze om de bekende
/// statusbalk (de "IUCN-map") te tekenen en de juiste categorie te markeren.
enum IucnStatus {
  notEvaluated('NE', 'Niet beoordeeld', Color(0xFFC1C1C1)),
  dataDeficient('DD', 'Onvoldoende gegevens', Color(0xFFD1D1C6)),
  leastConcern('LC', 'Niet bedreigd', Color(0xFF60C659)),
  nearThreatened('NT', 'Gevoelig', Color(0xFFCCE226)),
  vulnerable('VU', 'Kwetsbaar', Color(0xFFF9E814)),
  endangered('EN', 'Bedreigd', Color(0xFFFC7F3F)),
  criticallyEndangered('CR', 'Ernstig bedreigd', Color(0xFFD81E05)),
  extinctInWild('EW', 'Uitgestorven in het wild', Color(0xFF542344)),
  extinct('EX', 'Uitgestorven', Color(0xFF000000));

  const IucnStatus(this.code, this.labelNl, this.color);

  /// Officiële afkorting, bijv. `LC`.
  final String code;

  /// Nederlandse omschrijving, bijv. `Niet bedreigd`.
  final String labelNl;

  /// Officiële IUCN-categoriekleur.
  final Color color;
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
    required this.habitat,
    required this.diet,
    required this.weight,
    required this.lifespan,
    required this.offspring,
    required this.breedingTime,
    required this.iucnStatus,
    required this.bubbleFact,
    this.inEep = true,
    this.photoAsset,
    this.photoAlignment = Alignment.center,
    this.photoFit = BoxFit.cover,
    this.videoAsset,
    this.showVideo = true,
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

  // --- Gestructureerde steekkaart. Wordt altijd in deze vaste volgorde
  // getoond: leefgebied, voeding, gewicht, leeftijd, jongeren/eieren,
  // draag-/broedtijd. ---

  /// Leefgebied — waar het dier of koraal in het wild voorkomt.
  final String habitat;

  /// Voeding — wat het eet.
  final String diet;

  /// Gewicht (of formaat bij koralen die niet op gewicht te meten zijn).
  final String weight;

  /// Leeftijd — hoe oud het kan worden.
  final String lifespan;

  /// Jongeren / eieren — hoeveel nakomelingen of eieren.
  final String offspring;

  /// Draag- of broedtijd.
  final String breedingTime;

  /// IUCN Rode Lijst-status.
  final IucnStatus iucnStatus;

  /// Kort weetje dat in het paarse bolletje midden op de foto verschijnt.
  final String bubbleFact;

  /// Of het EEP-logo (EAZA Ex-situ Programme) getoond wordt.
  final bool inEep;

  /// Optioneel pad naar een echte foto (in `dier_fotos_hd/`). Als dit is
  /// ingevuld toont het detail-scherm de foto in plaats van de illustratie.
  final String? photoAsset;

  /// Uitsnede-uitlijning voor [photoAsset] bij `BoxFit.cover`. Standaard
  /// gecentreerd; verschuif (bijv. naar onderen) om een dier dat niet
  /// gecentreerd staat toch volledig in beeld te houden.
  final Alignment photoAlignment;

  /// Hoe [photoAsset] in de kaart past. `cover` vult de container (standaard);
  /// `contain` toont het hele dier (uitgezoomd) met achtergrond eromheen.
  final BoxFit photoFit;

  /// Optioneel pad naar een video over dit dier of koraal. Zolang dit leeg
  /// is toont het detail-scherm een gereserveerde video-plek (placeholder).
  final String? videoAsset;

  /// Of de video-container op het detail-scherm getoond wordt. Standaard aan;
  /// zet op `false` om de video-plek volledig weg te laten (de foto vult dan
  /// de hele media-ruimte).
  final bool showVideo;
}
