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
    photoAsset: 'lib/app/assets/dier_fotos_hd/IMG_1295.JPG',
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
    size: 1.30,
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
  ),
  InfoCreature(
    id: 'cabbage_leather_coral',
    dutchName: 'Kroepoeklederkoraal',
    scientificName: 'Sinularia sp.',
    category: 'Zacht koraal',
    kind: CreatureKind.cabbageLeatherCoral,
    position: Offset(0.28, 0.86),
    motion: CreatureMotion.sway,
    size: 1.25,
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
  ),
  InfoCreature(
    id: 'button_polyps',
    dutchName: 'Knopkoraal',
    scientificName: 'Zoanthus sp.',
    category: 'Poliepen',
    kind: CreatureKind.buttonPolyps,
    position: Offset(0.48, 0.92),
    motion: CreatureMotion.pulse,
    size: 1.15,
    colors: CreatureColors(
      primary: Color(0xFF6FB94B),
      secondary: Color(0xFFCEEB72),
      accent: Color(0xFF1F4A24),
    ),
    tagline: 'Een mat van piepkleine kleurige knopen.',
    description:
        'Knopkoralen vormen een tapijt van piepkleine kleurige poliepen, '
        'elk niet groter dan je vingernagel. Elk knoopje heeft een kring '
        'tentakels rond een mondje. Samen vangen ze plankton uit het water. '
        'Vooral onder blauw licht stralen ze fel groen, oranje of paars.',
    funFacts: [
      'Sommige soorten bevatten een gif (palytoxine) — niet aanraken!',
      'Kan zich snel uitbreiden over rotsen.',
      'Verzamelaars sparen kleurvariaties als zeldzame "morphs".',
    ],
  ),
  InfoCreature(
    id: 'coral_disc',
    dutchName: 'Koraalschijf',
    scientificName: 'Ricordea yuma',
    category: 'Poliep',
    kind: CreatureKind.coralDisc,
    position: Offset(0.68, 0.87),
    motion: CreatureMotion.pulse,
    size: 1.20,
    colors: CreatureColors(
      primary: Color(0xFFD5C82A),
      secondary: Color(0xFFEAE445),
      accent: Color(0xFF5B6D14),
    ),
    tagline: 'Platte poliep met bobbeltjes die glanzen onder blauw licht.',
    description:
        'De koraalschijf is een dikke platte poliep met overal kleine '
        'bobbeltjes op zijn rugzijde. Die bobbeltjes zitten vol met algen die '
        'energie geven uit zonlicht. Onder blauw aquariumlicht licht de '
        'koraalschijf fel groen of oranje op — alsof hij van neon is.',
    funFacts: [
      'Voortplanting door zichzelf in tweeën te splitsen.',
      'Vooral te vinden in de Caribische zee.',
      'Eet ook plankton en kleine garnaaltjes.',
    ],
  ),
  InfoCreature(
    id: 'hermit_crab',
    dutchName: 'Heremietkreeft',
    scientificName: 'Clibanarius tricolor',
    category: 'Kreeftachtige',
    kind: CreatureKind.hermitCrab,
    position: Offset(0.88, 0.86),
    motion: CreatureMotion.hover,
    size: 0.95,
    colors: CreatureColors(
      primary: Color(0xFF2F8AD9),
      secondary: Color(0xFFD8B484),
      accent: Color(0xFF6E2722),
    ),
    tagline: 'Draagt een slakkenhuis op de rug en heeft felblauwe pootjes.',
    description:
        'De heremietkreeft heeft geen eigen harde schaal, dus leent hij een '
        'leeg slakkenhuis als pantser. Zodra hij groter wordt, ruilt hij het '
        'om voor een groter exemplaar. Aan zijn felblauwe pootjes met witte '
        'stipjes herken je hem meteen tussen andere heremietkreeftjes.',
    funFacts: [
      'Helpt het rif schoon door algen en restjes voer op te eten.',
      'Bij gevaar trekt hij zich helemaal terug in zijn huisje.',
      'Soms vechten twee kreeftjes om hetzelfde huisje.',
    ],
  ),
];
