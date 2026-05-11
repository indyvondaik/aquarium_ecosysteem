import 'dart:math' as math;

import 'package:aquarium_ecosysteem/features/reef_balance/domain/reef_action.dart';

enum ReefMood { thriving, balanced, algaeBloom, hungry, overCleaned, crowded }

enum ReefRoundPhase { intro, reaction, result }

class ReefState {
  const ReefState({
    required this.algae,
    required this.fish,
    required this.crab,
    required this.actionsTaken,
    required this.eventId,
    required this.bestScore,
    required this.rippleX,
    required this.rippleY,
    required this.phase,
    required this.resultVisible,
    this.isAnimating = false,
    this.lastAction,
    this.firstAction,
  });

  static const initial = ReefState(
    algae: 52,
    fish: 50,
    crab: 6,
    actionsTaken: 0,
    eventId: 0,
    bestScore: 0,
    rippleX: 0.52,
    rippleY: 0.42,
    phase: ReefRoundPhase.intro,
    resultVisible: false,
  );

  final int algae;
  final int fish;
  final int crab;
  final int actionsTaken;
  final int eventId;
  final int bestScore;
  final double rippleX;
  final double rippleY;
  final ReefRoundPhase phase;
  final bool resultVisible;
  final bool isAnimating;
  final ReefAction? lastAction;
  final ReefAction? firstAction;

  int get healthScore {
    final algaePenalty = (algae - 52).abs() * 1.48;
    final fishPenalty = (fish - 52).abs() * 0.82;
    final crabPenalty = math.max(0, crab - 34) * 1.2;
    final hungerPenalty = math.max(0, 28 - algae) * 0.72;
    final score =
        100 -
        algaePenalty -
        fishPenalty -
        crabPenalty -
        hungerPenalty -
        crowdPenalty;
    return score.round().clamp(0, 100).toInt();
  }

  double get crowdPenalty => math.max(0, fish + crab - 108) * 0.42;

  int get reefScore => math.max(bestScore, healthScore);

  bool get isBalanced => healthScore >= 86;

  bool get isIntro => phase == ReefRoundPhase.intro;

  bool get isReaction => phase == ReefRoundPhase.reaction;

  bool get isResult => phase == ReefRoundPhase.result;

  bool get hasCompletedRound => isResult;

  bool get solvedRound =>
      isResult && firstAction != null && lastAction == idealCorrection;

  ReefAction? get idealCorrection {
    return switch (firstAction) {
      ReefAction.algae => ReefAction.fish,
      ReefAction.fish => ReefAction.algae,
      ReefAction.crab => ReefAction.algae,
      null => null,
    };
  }

  int get algaePatchCount => (5 + algae / 4.2).round().clamp(6, 32).toInt();

  int get fishCount => (1 + fish / 7).round().clamp(2, 18).toInt();

  int get crabCount => (crab / 9).round().clamp(0, 8).toInt();

  int get choicesLeft => switch (phase) {
    ReefRoundPhase.intro => 2,
    ReefRoundPhase.reaction => 1,
    ReefRoundPhase.result => 0,
  };

  String get stepLabel => switch (phase) {
    ReefRoundPhase.intro => 'Kies verandering',
    ReefRoundPhase.reaction => 'Kies oplossing',
    ReefRoundPhase.result => 'Resultaat',
  };

  String get headline {
    return switch (phase) {
      ReefRoundPhase.intro => 'Het rif bruist van leven!',
      ReefRoundPhase.reaction => observationTitle,
      ReefRoundPhase.result => solvedRound
          ? 'Topspeurder! Balans hersteld!'
          : 'Oeps, het rif blijft uit balans...',
    };
  }

  String get prompt {
    return switch (phase) {
      ReefRoundPhase.intro =>
        'Kies eerst wat bezoekers aan het rif veranderen.',
      ReefRoundPhase.reaction =>
        'Kijk naar het rif en kies de beste oplossing.',
      ReefRoundPhase.result =>
        solvedRound
            ? 'Goed gezien. Groei en eten zijn weer in evenwicht.'
            : 'Probeer opnieuw: kijk of er te veel of te weinig algen zijn.',
    };
  }

  String get observationTitle {
    if (phase == ReefRoundPhase.intro) {
      return 'Stralend rif';
    }

    return switch (mood) {
      ReefMood.algaeBloom => 'Algenexplosie!',
      ReefMood.hungry => 'Honger op het rif!',
      ReefMood.overCleaned => 'Te schoon rif!',
      ReefMood.crowded => 'Drukte op het rif!',
      ReefMood.thriving => 'Stralend rif!',
      ReefMood.balanced => 'Bijna in balans!',
    };
  }

  String get observationDetail {
    if (phase == ReefRoundPhase.intro) {
      return 'Algen, vissen en krabben werken samen. Wat een avontuur!';
    }

    if (phase == ReefRoundPhase.result) {
      return solvedRound
          ? 'Wat een topspeurder! Het rif danst weer in balans.'
          : incorrectReason;
    }

    return switch (mood) {
      ReefMood.algaeBloom =>
        'Wow, het rif zit vol algen! Het koraal krijgt geen zonlicht meer. '
            'Wie smult van algen?',
      ReefMood.hungry =>
        'De algen zijn bijna op! Wie geeft de vissen nu nog te eten?',
      ReefMood.overCleaned =>
        'Brandschoon rif! Maar zonder algen valt er niets meer te ontdekken.',
      ReefMood.crowded =>
        'Wat een drukte! Er zwemmen meer vissen dan er voedsel is.',
      ReefMood.thriving =>
        'Topboel! Kleur, voedsel en avontuur in overvloed.',
      ReefMood.balanced =>
        'Bijna in balans! Eén kleine speurtocht en het klopt weer.',
    };
  }

  String get incorrectReason {
    return switch (firstAction) {
      ReefAction.algae =>
        'De extra algen zijn niet weggegeten. Weet je wie van algen smult? '
            'Vissen!',
      ReefAction.fish =>
        'De vissen hebben honger. Voeg algen toe zodat ze weer kunnen smullen.',
      ReefAction.crab =>
        'De krabben hebben alles te schoon gemaakt. Tijd om nieuwe algen '
            'terug te brengen!',
      null => 'Speur het rif af en probeer opnieuw, ontdekkingsreiziger!',
    };
  }

  String get resultBanner {
    if (phase != ReefRoundPhase.result) {
      return 'Zie je te weinig algen? Voeg algen toe. Zie je te veel algen? Voeg vissen toe.';
    }

    return solvedRound
        ? 'Top. Je koos precies de tegenreactie die het rif nodig had.'
        : 'Krabben versterken een verandering, maar lossen het probleem niet op.';
  }

  String get autoResetLabel {
    return solvedRound
        ? 'Nieuw spel start zo vanzelf.'
        : 'Nog even kijken... daarna begint automatisch een nieuw spel.';
  }

  String get sceneStatus {
    return switch (mood) {
      ReefMood.algaeBloom => 'Groen rif',
      ReefMood.hungry => 'Weinig voedsel',
      ReefMood.overCleaned => 'Te schoon',
      ReefMood.crowded => 'Te druk',
      ReefMood.thriving => 'Stralend rif',
      ReefMood.balanced => 'Rustig rif',
    };
  }

  ReefAction? get highlightedAction {
    if (phase != ReefRoundPhase.reaction) {
      return null;
    }
    return idealCorrection;
  }

  bool actionEnabled(ReefAction action) =>
      phase != ReefRoundPhase.result && !isAnimating;

  int valueFor(ReefAction action) {
    return switch (action) {
      ReefAction.algae => algae,
      ReefAction.fish => fish,
      ReefAction.crab => crab,
    };
  }

  ReefMood get mood {
    if (algae >= 76) {
      return ReefMood.algaeBloom;
    }
    if (crab >= 30 && algae <= 26) {
      return ReefMood.overCleaned;
    }
    if (algae <= 26) {
      return ReefMood.hungry;
    }
    if (fish + crab >= 118) {
      return ReefMood.crowded;
    }
    if (healthScore >= 94) {
      return ReefMood.thriving;
    }
    return ReefMood.balanced;
  }

  String get moodTitle {
    return switch (mood) {
      ReefMood.thriving => 'Het rif schittert',
      ReefMood.balanced => 'Rif in balans',
      ReefMood.algaeBloom => 'Algen nemen ruimte',
      ReefMood.hungry => 'Weinig rifvoedsel',
      ReefMood.overCleaned => 'Te hard opgeruimd',
      ReefMood.crowded => 'Druk op het rif',
    };
  }

  String get moodMessage {
    if (phase == ReefRoundPhase.result) {
      return resultBanner;
    }

    if (lastAction != null && phase != ReefRoundPhase.intro) {
      return lastAction!.spawnCopy;
    }

    return switch (mood) {
      ReefMood.thriving => 'Veel kleur, helder water en genoeg voedsel.',
      ReefMood.balanced =>
        'Alles voelt rustig: houd groei en eten in evenwicht.',
      ReefMood.algaeBloom => 'Meer grazers helpen het koraal vrij te houden.',
      ReefMood.hungry => 'Laat algen terugkomen zodat er weer eten is.',
      ReefMood.overCleaned =>
        'Krabben helpen, maar kunnen ook te veel weghalen.',
      ReefMood.crowded => 'Veel dieren betekent meer beweging en minder rust.',
    };
  }

  String get coachLine {
    return prompt;
  }

  String get latestFact {
    if (phase == ReefRoundPhase.reaction) {
      return observationDetail;
    }

    return lastAction?.fact ??
        'Een gezond rif voelt als een team: algen, vissen en krabben houden elkaar samen in beweging.';
  }

  ReefState copyWith({
    int? algae,
    int? fish,
    int? crab,
    int? actionsTaken,
    int? eventId,
    int? bestScore,
    double? rippleX,
    double? rippleY,
    ReefRoundPhase? phase,
    bool? resultVisible,
    bool? isAnimating,
    ReefAction? lastAction,
    ReefAction? firstAction,
    bool clearLastAction = false,
    bool clearFirstAction = false,
  }) {
    return ReefState(
      algae: algae ?? this.algae,
      fish: fish ?? this.fish,
      crab: crab ?? this.crab,
      actionsTaken: actionsTaken ?? this.actionsTaken,
      eventId: eventId ?? this.eventId,
      bestScore: bestScore ?? this.bestScore,
      rippleX: rippleX ?? this.rippleX,
      rippleY: rippleY ?? this.rippleY,
      phase: phase ?? this.phase,
      resultVisible: resultVisible ?? this.resultVisible,
      isAnimating: isAnimating ?? this.isAnimating,
      lastAction: clearLastAction ? null : lastAction ?? this.lastAction,
      firstAction: clearFirstAction ? null : firstAction ?? this.firstAction,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReefState &&
            other.algae == algae &&
            other.fish == fish &&
            other.crab == crab &&
            other.actionsTaken == actionsTaken &&
            other.eventId == eventId &&
            other.bestScore == bestScore &&
            other.rippleX == rippleX &&
            other.rippleY == rippleY &&
            other.phase == phase &&
            other.resultVisible == resultVisible &&
            other.isAnimating == isAnimating &&
            other.lastAction == lastAction &&
            other.firstAction == firstAction;
  }

  @override
  int get hashCode {
    return Object.hash(
      algae,
      fish,
      crab,
      actionsTaken,
      eventId,
      bestScore,
      rippleX,
      rippleY,
      lastAction,
      phase,
      resultVisible,
      isAnimating,
      firstAction,
    );
  }
}
