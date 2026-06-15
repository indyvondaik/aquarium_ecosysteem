import 'package:flutter_riverpod/flutter_riverpod.dart';

/// De fase waarin het ecosysteem-spel zich bevindt nadat het geopend is.
enum EcosystemPhase {
  /// Keuze-popup: eerst de uitlegvideo kijken of meteen starten.
  choosing,

  /// De uitleg(video) is zichtbaar als overlay over het spel.
  tutorial,

  /// Het spel is speelbaar.
  playing,
}

final ecosystemPhaseProvider =
    NotifierProvider<EcosystemPhaseController, EcosystemPhase>(
      EcosystemPhaseController.new,
    );

class EcosystemPhaseController extends Notifier<EcosystemPhase> {
  @override
  EcosystemPhase build() => EcosystemPhase.choosing;

  /// Begin opnieuw bij de keuze-popup. Wordt elke keer aangeroepen wanneer het
  /// spel vanuit het menu geopend wordt, zodat de speler altijd eerst de keuze
  /// krijgt: uitleg kijken of meteen starten.
  void restart() => state = EcosystemPhase.choosing;

  /// Toon de uitleg(video). Vanuit het spel zelf wordt de spelstand hieronder
  /// bewaard, zodat de speler daarna verdergaat waar die was.
  void showTutorial() => state = EcosystemPhase.tutorial;

  /// Sluit de keuze/uitleg en speel (verder). De spelstand blijft behouden.
  void play() => state = EcosystemPhase.playing;
}
