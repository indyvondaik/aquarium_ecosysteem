import 'package:aquarium_ecosysteem/features/quiz/data/quiz_question.dart';

const List<QuizQuestion> quizCatalog = [
  QuizQuestion(
    id: 'foxface_mask',
    dutchName: 'Vossenkop',
    scientificName: 'Siganus vulpinus',
    wrongImagePath: 'lib/app/assets/quiz_fotos/Vossenkop_fout.png',
    correctImagePath: 'lib/app/assets/quiz_fotos/IMG_1262.JPG',
    imageAspectRatio: 3 / 2,
    question: 'Wat klopt er niet aan deze foto?',
    questionTip: 'Tip: kijk in het aquarium en vind hem!',
    answers: [
      'Zwarte masker',
      'Verkeerde kleur',
      'Te korte staart',
    ],
    correctIndex: 0,
    correctTitle: 'Goed gedaan!',
    correctExplanation:
        'De vossenkop heeft eigenlijk een opvallend zwart-wit gezichtsmasker '
        '— net als een vos. Het masker verbergt zijn ogen zodat roofvissen '
        'niet meteen weten waar hij kijkt, en bij gevaar zet hij zijn '
        'giftige stekels overeind. Een echte slimmerik van het rif!',
  ),
  QuizQuestion(
    id: 'leather_coral_shape',
    dutchName: 'Lederkoraal',
    scientificName: 'Sarcophyton sp.',
    wrongImagePath: 'lib/app/assets/quiz_fotos/Koraal_fout.png',
    correctImagePath: 'lib/app/assets/quiz_fotos/IMG_1280.JPG',
    imageAspectRatio: 3 / 2,
    question:
        'Dit koraal zit ergens in het aquarium, maar de vorm klopt niet '
        'helemaal. Kan jij vinden welke vorm hij heeft?',
    questionTip: 'Tip: kijk in het aquarium en vind hem!',
    answers: [
      'Driehoek',
      'Vierkant',
      'Hartje',
    ],
    correctIndex: 2,
    correctTitle: 'Goed gedaan!',
    correctExplanation:
        'Dit lederkoraal groeit in het aquarium precies als een hartje! '
        'Omdat het zacht is, kan het koraal van vorm veranderen — soms een '
        'hartje, soms een bolletje. Als het water rustig is, strekt hij al '
        'zijn kleine poliepjes uit om plankton uit het water te vangen.',
  ),
  QuizQuestion(
    id: 'seahorse_fin',
    dutchName: 'Zeepaardje',
    scientificName: 'Hippocampus reidi',
    wrongImagePath: 'lib/app/assets/quiz_fotos/Zeepaardje_fout.png',
    correctImagePath: 'lib/app/assets/quiz_fotos/IMG_1447.JPG',
    imageAspectRatio: 3 / 2,
    question: 'Het zeepaardje mist iets heel belangrijks. Wat mist het '
        'zeepaardje?',
    questionTip: 'Tip: kijk in het aquarium en vind hem!',
    answers: [
      'Een derde oog',
      'Vin op zijn rug',
      '2 poten',
    ],
    correctIndex: 1,
    correctTitle: 'Goed gedaan!',
    correctExplanation:
        'Het zeepaardje heeft een waaiervormige vin op zijn rug. Die wappert '
        'wel dertig keer per seconde en daarmee zwemt hij rechtop door het '
        'water. Zonder zijn rugvin zou het zeepaardje geen kant op kunnen!',
  ),
  QuizQuestion(
    id: 'copperband_dot',
    dutchName: 'Pincetvis',
    scientificName: 'Chelmon rostratus',
    wrongImagePath: 'lib/app/assets/quiz_fotos/Pincetvis_fout.png',
    correctImagePath: 'lib/app/assets/quiz_fotos/IMG_1251.JPG',
    imageAspectRatio: 3 / 2,
    question: 'Er klopt hier iets niet aan de foto. Wat mist er hier?',
    questionTip: 'Tip: kijk in het aquarium en vind hem!',
    answers: [
      'Groene bek',
      'Zwarte stip',
      'Roze staart',
    ],
    correctIndex: 1,
    correctTitle: 'Goed gedaan!',
    correctExplanation:
        'De pincetvis heeft een zwarte stip op zijn rugvin die op een nep-oog '
        'lijkt. Roofvissen happen zo naar de verkeerde kant, terwijl zijn '
        'echte ogen veilig achter een donkere streep verstopt zitten. Slim!',
  ),
];
