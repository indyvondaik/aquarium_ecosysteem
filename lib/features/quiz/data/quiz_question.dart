class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.dutchName,
    required this.scientificName,
    required this.wrongImagePath,
    required this.correctImagePath,
    required this.imageAspectRatio,
    required this.question,
    required this.questionTip,
    required this.answers,
    required this.correctIndex,
    required this.correctTitle,
    required this.correctExplanation,
  });

  final String id;
  final String dutchName;
  final String scientificName;

  /// Foto die getoond wordt vóór het antwoord — bevat de "fout" waar de
  /// vraag over gaat (bv. een vossenkop zonder zijn zwart-witte masker).
  final String wrongImagePath;

  /// Echte foto die ná het juiste antwoord verschijnt zodat het kind
  /// ziet hoe het dier er werkelijk uitziet.
  final String correctImagePath;

  /// Breedte/hoogte van het bronbeeld — beide foto's hebben dezelfde
  /// verhouding zodat het frame niet verspringt bij de wissel.
  final double imageAspectRatio;

  final String question;
  final String questionTip;

  /// Drie (of meer) antwoorden in volgorde.
  final List<String> answers;
  final int correctIndex;

  final String correctTitle;
  final String correctExplanation;
}
