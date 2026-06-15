import 'package:aquarium_ecosysteem/features/info_aquarium/data/info_creature.dart';
import 'package:flutter/painting.dart';

/// De 9 organismen die in het info-aquarium leven. Het zeepaardje staat
/// centraal en is wat groter — het is het kenmerkende dier van dit aquarium.
const List<InfoCreature> creatureCatalog = [
  // --- Hoofdrolspeler: zeepaardje in het midden ---
  InfoCreature(
    id: 'seahorse',
    dutchName: 'Zeepaardje',
    scientificName: 'Hippocampus reidi',
    category: 'Vis',
    kind: CreatureKind.seahorse,
    position: Offset(0.50, 0.42),
    motion: CreatureMotion.bob,
    size: 1.6,
    colors: CreatureColors(
      primary: Color(0xFFE6A634),
      secondary: Color(0xFFF8D78A),
      accent: Color(0xFF5C2C0E),
    ),
    tagline: 'Zwemt rechtop met een krullende staart.',
    description:
        'Het zeepaardje is een bijzondere vis die rechtop zwemt met behulp '
        'van een waaiervormige rugvin. Met zijn grijpstaart pakt hij zeegras '
        'of koraal vast om uit te rusten. Bijzonder: het mannetje draagt de '
        'eitjes in een buidel op zijn buik tot ze uitkomen!',
    funFacts: [
      'Heeft geen schubben maar een pantser van benige plaatjes.',
      'Eet kleine garnaaltjes door ze met zijn snuit op te zuigen.',
      'Trouw aan één partner gedurende het hele jaar.',
    ],
    habitat: 'Warme, ondiepe kustwateren van de westelijke Atlantische '
        'Oceaan, tussen zeegras en mangroves.',
    diet: 'Kleine garnaaltjes, vislarven en plankton — opgezogen met de snuit.',
    weight: 'Tot ongeveer 10 gram',
    lifespan: '1 tot 4 jaar',
    offspring: '100 tot 1000 eitjes per keer',
    breedingTime: 'Mannetje draagt de eitjes ±2 weken',
    iucnStatus: IucnStatus.nearThreatened,
    bubbleFact: 'Het mannetje zwanger wordt en de baby\'s krijgt!',
    videoAsset: 'lib/app/assets/informatie_videos/zeepaardje.mp4',
    photoAsset: 'lib/app/assets/dier_fotos_hd/IMG_1319.JPG',
    // Vult de container (cover) met een uitsnede die zoveel mogelijk van het
    // lichaam toont — kop én het grootste deel van de staart.
    photoAlignment: Alignment(0, 0.4),
  ),

  // --- Bovenste waterlaag: vissen aan de zijkanten ---
  InfoCreature(
    id: 'foxface',
    dutchName: 'Vossenkop',
    scientificName: 'Siganus vulpinus',
    category: 'Vis',
    kind: CreatureKind.foxface,
    position: Offset(0.22, 0.26),
    motion: CreatureMotion.hover,
    size: 0.95,
    colors: CreatureColors(
      primary: Color(0xFFFFD23F),
      secondary: Color(0xFFFFFFFF),
      accent: Color(0xFF1A1A1A),
    ),
    tagline: 'Knalgeel met een zwart-wit gemaskerd snoetje.',
    description:
        'De vossenkop dankt zijn naam aan zijn opvallende zwart-witte '
        'gezichtsmasker dat doet denken aan een vos. Hij heeft giftige '
        'stekels in zijn rugvin die hij omhoog zet als hij zich bedreigd '
        'voelt. Verder is hij heel rustig en knabbelt graag aan algen.',
    funFacts: [
      'Zwemt vaak in paren.',
      'Helpt het rif door overtollige algen weg te eten.',
      'Bij stress kleurt zijn lichaam tijdelijk donkerder.',
    ],
    habitat: 'Koraalriffen in de westelijke Stille Oceaan, van Indonesië tot '
        'de Filipijnen.',
    diet: 'Vooral algen die hij van het rif afgraast (planteneter).',
    weight: 'Tot ongeveer 200 gram',
    lifespan: '5 tot 8 jaar',
    offspring: 'Legt eitjes die vrij in het water zweven',
    breedingTime: 'Eitjes komen na ±1 dag uit',
    iucnStatus: IucnStatus.leastConcern,
    bubbleFact: 'Zijn rugvin vol giftige stekels zit!',
    videoAsset: 'lib/app/assets/informatie_videos/vossenkop.mp4',
    photoAsset: 'lib/app/assets/dier_fotos_hd/IMG_1262.JPG',
  ),
  InfoCreature(
    id: 'copperband',
    dutchName: 'Pincetvis',
    scientificName: 'Chelmon rostratus',
    category: 'Vis',
    kind: CreatureKind.copperband,
    position: Offset(0.78, 0.26),
    motion: CreatureMotion.hover,
    size: 0.95,
    colors: CreatureColors(
      primary: Color(0xFFF0F2F4),
      secondary: Color(0xFFEB8A2A),
      accent: Color(0xFF14223D),
    ),
    tagline: 'Lange snuit als een pincet om wormpjes te pakken.',
    description:
        'De pincetvis heeft een lange smalle bek waarmee hij precies in '
        'spleetjes van het koraal kan pikken. Daar haalt hij kleine wormpjes '
        'en garnaaltjes vandaan. Zijn felle oranje strepen verwarren '
        'roofvissen die zijn ogen niet kunnen vinden.',
    funFacts: [
      'De zwarte stip op zijn rugvin lijkt op een nep-oog.',
      'Aaseter van glasanemonen — handig in een aquarium.',
      'Zwemt vaak in paren langs het rif.',
    ],
    habitat: 'Riffen en troebele kustwateren van de Indische en westelijke '
        'Stille Oceaan.',
    diet: 'Wormpjes, kleine kreeftachtigen en anemoontjes uit spleetjes.',
    weight: 'Tot ongeveer 90 gram',
    lifespan: '4 tot 6 jaar',
    offspring: 'Legt kleine, vrij zwevende eitjes',
    breedingTime: 'Eitjes komen binnen ±1 dag uit',
    iucnStatus: IucnStatus.leastConcern,
    bubbleFact: 'De zwarte stip op een nep-oog lijkt!',
    videoAsset: 'lib/app/assets/informatie_videos/pincetvis.mp4',
    photoAsset: 'lib/app/assets/dier_fotos_hd/IMG_1251.JPG',
    // Verder naar onderen uitgesneden zodat er niets onderaan wordt afgesneden.
    photoAlignment: Alignment(0, 0.6),
  ),
  InfoCreature(
    id: 'yellow_wrasse',
    dutchName: 'Gele lipvis',
    scientificName: 'Halichoeres leucoxanthus',
    category: 'Vis',
    kind: CreatureKind.yellowWrasse,
    position: Offset(0.22, 0.60),
    motion: CreatureMotion.hover,
    size: 0.90,
    colors: CreatureColors(
      primary: Color(0xFFFFD53A),
      secondary: Color(0xFFE3F4FB),
      accent: Color(0xFF4A7DAF),
    ),
    tagline: 'Snelle gele zwemmer die zich \'s nachts ingraaft.',
    description:
        'De gele lipvis is een actieve zwemmer die de hele dag heen en weer '
        'flitst op zoek naar wormpjes en kleine kreeftachtigen. Als de avond '
        'valt duikt hij in het zand om veilig te slapen. \'s Ochtends komt '
        'hij weer tevoorschijn alsof er niks gebeurd is.',
    funFacts: [
      'Verandert van kleur als hij volwassen wordt.',
      'Geboren als vrouwtje — sommige worden later mannetje.',
      'Eet parasieten van andere vissen.',
    ],
    habitat: 'Zandige bodems naast riffen in de Indische Oceaan en de '
        'westelijke Stille Oceaan.',
    diet: 'Kleine ongewervelden, wormpjes en parasieten van andere vissen.',
    weight: 'Tot ongeveer 25 gram',
    lifespan: '3 tot 5 jaar',
    offspring: 'Legt vrij zwevende eitjes',
    breedingTime: 'Eitjes komen binnen ±1 dag uit',
    iucnStatus: IucnStatus.leastConcern,
    bubbleFact: 'Hij zich \'s nachts in het zand ingraaft om te slapen!',
    photoAsset: 'lib/app/assets/dier_fotos_hd/IMG_1295.JPG',
    showVideo: false,
  ),

  // --- Onderste laag: koralen en bodembewoners ---
  InfoCreature(
    id: 'finger_leather_coral',
    dutchName: 'Vingerlederkoraal',
    scientificName: 'Sarcophyton sp.',
    category: 'Zacht koraal',
    kind: CreatureKind.fingerLeatherCoral,
    position: Offset(0.10, 0.85),
    motion: CreatureMotion.pulse,
    size: 0.95,
    colors: CreatureColors(
      primary: Color(0xFFD1B07A),
      secondary: Color(0xFFF1E2C0),
      accent: Color(0xFF8C6E3C),
    ),
    tagline: 'Een mound vol fluwelen poliep-tentakels.',
    description:
        'Het vingerlederkoraal zit als een dik kussen op de bodem en steekt '
        'overal kleine tentakeltjes (poliepen) uit. Overdag staan de poliepen '
        'uit om plankton uit het water te vangen; \'s nachts trekken ze zich '
        'in. Het is een echt zacht koraal: je kunt het bijna aaien.',
    funFacts: [
      'Kan tot 80 cm doorsnee worden.',
      'Geeft via algen in zijn weefsel zelf voedsel terug.',
      'Hervindt zich snel als er een stukje afbreekt.',
    ],
    habitat: 'Ondiepe, lichtrijke riffen in de Indische en Stille Oceaan.',
    diet: 'Suikers van algen (zoöxanthellen) in zijn weefsel én plankton.',
    weight: 'Kolonie tot ±80 cm doorsnee',
    lifespan: 'Kolonie kan tientallen jaren leven',
    offspring: 'Larven (planula) en afgebroken stukjes groeien uit',
    breedingTime: 'Paait enkele keren per jaar',
    iucnStatus: IucnStatus.notEvaluated,
    bubbleFact: 'Je dit zachte koraal bijna kunt aaien!',
    photoAsset: 'lib/app/assets/dier_fotos_hd/IMG_1193.JPG',
    photoAlignment: Alignment(0, 0.2),
    showVideo: false,
  ),
  InfoCreature(
    id: 'cabbage_leather_coral',
    dutchName: 'Kroepoeklederkoraal',
    scientificName: 'Sinularia sp.',
    category: 'Zacht koraal',
    kind: CreatureKind.cabbageLeatherCoral,
    position: Offset(0.28, 0.86),
    motion: CreatureMotion.sway,
    size: 0.95,
    colors: CreatureColors(
      primary: Color(0xFFE6A9B0),
      secondary: Color(0xFFF7D5D2),
      accent: Color(0xFFA85F6A),
    ),
    tagline: 'Roze takken die uitwaaieren als een handpalm.',
    description:
        'Het kroepoeklederkoraal heeft dikke, vingervormige takken die '
        'omhoog en naar buiten waaieren als een hand. Tussen de takken '
        'verstoppen zich graag kleine garnaaltjes en gobies. Het koraal '
        'beweegt zacht mee met de stroming, alsof het ademt.',
    funFacts: [
      'Vormt grote kolonies van vele meters breed.',
      'Geeft een laag slijm af om zich schoon te houden.',
      'Concurreert met hard koraal om ruimte op het rif.',
    ],
    habitat: 'Lichtrijke rifhellingen in de Indo-Pacific.',
    diet: 'Suikers van algen in zijn weefsel én opgevangen plankton.',
    weight: 'Kolonie tot enkele meters breed',
    lifespan: 'Kolonie kan tientallen jaren leven',
    offspring: 'Larven en uitlopers vormen nieuwe kolonies',
    breedingTime: 'Paait seizoensgebonden',
    iucnStatus: IucnStatus.notEvaluated,
    bubbleFact: 'Het slijm afgeeft om zichzelf schoon te houden!',
    photoAsset: 'lib/app/assets/dier_fotos_hd/IMG_1256.JPG',
    showVideo: false,
  ),
  InfoCreature(
    id: 'button_polyps',
    dutchName: 'Knopkoraal',
    scientificName: 'Palythoa sp.',
    category: 'Poliepen',
    kind: CreatureKind.buttonPolyps,
    position: Offset(0.48, 0.92),
    motion: CreatureMotion.pulse,
    size: 0.90,
    colors: CreatureColors(
      primary: Color(0xFF6FB94B),
      secondary: Color(0xFFCEEB72),
      accent: Color(0xFF1F4A24),
    ),
    tagline: 'Knopvormige poliepjes op één mat — mét een sterk gif.',
    description:
        'Palythoa groeit als een dikke mat van knopvormige poliepjes die met '
        'een vlezige laag aan elkaar vastzitten. Elk poliepje heeft een kransje '
        'korte tentakels rond een mondje waarmee het plankton vangt. Het '
        'grootste deel van zijn voedsel maakt het echter zelf met algen in zijn '
        'weefsel die zonlicht omzetten in suiker. Let op: deze koralen bevatten '
        'palytoxine, een van de sterkste natuurlijke giffen.',
    funFacts: [
      'Bevat palytoxine — een van de giftigste stoffen in de natuur.',
      'De poliepen zitten met een gemeenschappelijke vlezige mat vast.',
      'Breidt zich snel uit door nieuwe poliepen over de rots te klonen.',
    ],
    habitat: 'Ondiepe, zonnige riffen in tropische zeeën, vastgehecht op rots '
        'en koraalpuin.',
    diet: 'Vooral suikers van algen (zoöxanthellen) in zijn weefsel, aangevuld '
        'met plankton.',
    weight: 'Kolonie van poliepjes, elk tot ±1 cm',
    lifespan: 'Kolonie groeit jarenlang door',
    offspring: 'Breidt uit door deling (kloonpoliepen)',
    breedingTime: 'Kan het hele jaar door delen',
    iucnStatus: IucnStatus.notEvaluated,
    bubbleFact: 'Hij palytoxine bevat — een van de sterkste giffen in de natuur!',
    photoAsset: 'lib/app/assets/dier_fotos_hd/IMG_1247.JPG',
    showVideo: false,
  ),
  InfoCreature(
    id: 'coral_disc',
    dutchName: 'Koraalschijf',
    scientificName: 'Discosoma sp.',
    category: 'Schijfanemoon',
    kind: CreatureKind.coralDisc,
    position: Offset(0.68, 0.87),
    motion: CreatureMotion.pulse,
    size: 0.92,
    colors: CreatureColors(
      primary: Color(0xFFD5C82A),
      secondary: Color(0xFFEAE445),
      accent: Color(0xFF5B6D14),
    ),
    tagline: 'Gladde, ronde schijf als een paddenstoel op de rots.',
    description:
        'De koraalschijf (Discosoma) is een platte, ronde poliep die op een '
        'paddenstoel lijkt. Zijn gladde schijf zit vol algen die van zonlicht '
        'suiker maken — daar leeft hij vooral van. Lange tentakels heeft hij '
        'bijna niet, maar hij kan toch kleine deeltjes uit het water opnemen. '
        'Discosoma is enorm sterk: hij verdraagt weinig licht en stroming en '
        'groeit daardoor bijna overal.',
    funFacts: [
      'Plant zich voort door zichzelf in tweeën te splitsen.',
      'Heel sterk: verdraagt weinig licht en weinig stroming.',
      'Onder blauw licht licht hij fel groen of blauw op.',
    ],
    habitat: 'Ondiepe tot diepere riffen in de Indo-Pacific, vaak op luwe, '
        'beschutte plekken.',
    diet: 'Vooral suikers van algen in zijn weefsel, aangevuld met opgenomen '
        'deeltjes en plankton.',
    weight: 'Schijf van enkele centimeters',
    lifespan: 'Leeft en deelt jarenlang door',
    offspring: 'Plant zich voort door zichzelf te splitsen',
    breedingTime: 'Kan het hele jaar door delen',
    iucnStatus: IucnStatus.notEvaluated,
    bubbleFact: 'Hij op een paddenstoel lijkt en zich in tweeën splitst!',
    photoAsset: 'lib/app/assets/dier_fotos_hd/IMG_1267.JPG',
    showVideo: false,
  ),
  InfoCreature(
    id: 'hermit_crab',
    dutchName: 'Heremietkreeft',
    scientificName: 'Calcinus elegans',
    category: 'Kreeftachtige',
    kind: CreatureKind.hermitCrab,
    position: Offset(0.88, 0.86),
    motion: CreatureMotion.hover,
    size: 0.88,
    colors: CreatureColors(
      primary: Color(0xFF2F8AD9),
      secondary: Color(0xFFD8B484),
      accent: Color(0xFF6E2722),
    ),
    tagline: 'Zwarte pootjes met elektrisch-blauwe lijnen en een geleend huisje.',
    description:
        'De Calcinus elegans is een sierlijke heremietkreeft die opvalt door '
        'zijn zwarte pootjes met elektrisch-blauwe lijnen en oranje accenten. '
        'Net als alle heremietkreeften heeft hij geen eigen harde schaal, dus '
        'leent hij een leeg slakkenhuis als pantser. Wordt hij te groot, dan '
        'ruilt hij het om voor een groter huisje. Overdag scharrelt hij over '
        'het rif op zoek naar algen en etensresten.',
    funFacts: [
      'Zijn zwarte poten zijn getekend met felblauwe lijnen — daar dankt hij '
          'zijn naam "elegans" aan.',
      'Helpt het rif schoon te houden door algen en etensresten op te eten.',
      'Soms vechten twee kreeftjes om hetzelfde slakkenhuis.',
    ],
    habitat: 'Ondiepe koraalriffen en getijdenpoelen in de Indo-Pacific, van '
        'de Rode Zee tot Hawaï.',
    diet: 'Algen, etensresten en aas — een echte opruimer.',
    weight: 'Heel licht, enkele grammen',
    lifespan: '2 tot 4 jaar',
    offspring: 'Vrouwtje draagt vele kleine eitjes',
    breedingTime: 'Larven zwerven daarna als plankton rond',
    iucnStatus: IucnStatus.notEvaluated,
    bubbleFact: 'Hij een leeg slakkenhuis als pantser leent!',
    photoAsset: 'lib/app/assets/dier_fotos_hd/heremietkreeft.jpg',
    videoAsset: 'lib/app/assets/informatie_videos/kreeft.mp4',
  ),
  InfoCreature(
    id: 'cleaner_shrimp',
    dutchName: 'Poetsgarnaal',
    scientificName: 'Lysmata amboinensis',
    category: 'Kreeftachtige',
    kind: CreatureKind.cleanerShrimp,
    position: Offset(0.79, 0.58),
    motion: CreatureMotion.hover,
    size: 0.95,
    colors: CreatureColors(
      primary: Color(0xFFE0492C),
      secondary: Color(0xFFF3E3C2),
      accent: Color(0xFFF2B23C),
    ),
    tagline: 'Pikt parasieten van grote vissen — een echte poetsbeurt.',
    description:
        'De poetsgarnaal is de schoonmaker van het rif. Op een vaste plek — '
        'een "poetsstation" — zwaait hij met zijn lange witte voelsprieten om '
        'vissen te lokken. Een grote vis blijft dan stil hangen terwijl de '
        'garnaal over zijn lijf en zelfs in zijn bek en kieuwen kruipt om '
        'parasieten en dode huid op te eten. De vis wordt schoon, de garnaal '
        'krijgt een maaltijd: iedereen blij!',
    funFacts: [
      'Vissen die hem normaal zouden opeten, laten hem rustig hun bek poetsen.',
      'Is mannetje én vrouwtje tegelijk (hermafrodiet).',
      'Wappert met zijn witte sprieten als reclame: "kom poetsen!".',
    ],
    habitat: 'Koraalriffen in de Indische en Stille Oceaan, vaak in spleten en '
        'grotjes die hij als vast poetsstation gebruikt.',
    diet: 'Parasieten, dode huid en etensresten die hij van andere vissen '
        'plukt.',
    weight: 'Heel licht, enkele grammen',
    lifespan: '2 tot 4 jaar',
    offspring: 'Draagt honderden eitjes onder zijn buik',
    breedingTime: 'Larven zweven daarna weken als plankton rond',
    iucnStatus: IucnStatus.notEvaluated,
    bubbleFact: 'Hij zelfs in de bek van grote vissen kruipt om te poetsen!',
    photoAsset: 'lib/app/assets/dier_fotos_hd/poetsgarnaal.jpg',
    videoAsset: 'lib/app/assets/informatie_videos/garnaal.mp4',
  ),
];
