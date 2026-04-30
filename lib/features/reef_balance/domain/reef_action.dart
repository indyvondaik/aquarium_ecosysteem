enum ReefAction { algae, fish, crab }

extension ReefActionCopy on ReefAction {
  String get label {
    return switch (this) {
      ReefAction.algae => 'Algen',
      ReefAction.fish => 'Vissen',
      ReefAction.crab => 'Krabben',
    };
  }

  String get buttonLabel {
    return switch (this) {
      ReefAction.algae => 'Meer algen',
      ReefAction.fish => 'Meer vissen',
      ReefAction.crab => 'Meer krabben',
    };
  }

  String get ecosystemRole {
    return switch (this) {
      ReefAction.algae => 'maken zuurstof en voedsel',
      ReefAction.fish => 'grazen algen weg',
      ReefAction.crab => 'ruimen de bodem op',
    };
  }

  String get spawnCopy {
    return switch (this) {
      ReefAction.algae => 'Nieuwe algen wiegen tussen het koraal.',
      ReefAction.fish => 'Een school vissen schiet het rif in.',
      ReefAction.crab => 'Krabben wandelen over de rifbodem.',
    };
  }

  String get fact {
    return switch (this) {
      ReefAction.algae =>
        'Algen zijn klein, maar ze geven veel leven in het rif energie.',
      ReefAction.fish =>
        'Plantetende vissen helpen voorkomen dat algen het koraal overnemen.',
      ReefAction.crab =>
        'Opruimers houden plek vrij, maar te veel opruimers eten ook veel weg.',
    };
  }
}
