import 'weather.dart';

/// One short piece of advice for the farmer's own region, right now.
class FarmTip {
  final String title;
  final String body;
  const FarmTip(this.title, this.body);
}

/// "This week on your farm".
///
/// This is the part of the app that works with no internet and no AI at all. It
/// is stored knowledge, chosen by the farmer's agro-climatic region and the
/// current season — the same two facts we already know from the setup screens.
///
/// Why it is worth having: the dashboard should be useful the moment it opens,
/// before the farmer has asked anything. An app that only responds is an app you
/// have to remember to use.
///
/// Deliberately no doses, no product names, and nothing that could cost money if
/// it is wrong. These are scouting and timing reminders — the advice a neighbour
/// with forty years of experience would give in one sentence.
FarmTip tipFor({
  required String region,
  required FarmingSeason season,
  required String lang,
}) {
  final seasonKey = switch (season) {
    FarmingSeason.kharif => 'kharif',
    FarmingSeason.rabi => 'rabi',
    FarmingSeason.summer => 'summer',
  };

  final byRegion = _tips[region] ?? _tips['Western Maharashtra']!;
  final bySeason = byRegion[seasonKey]!;
  final pair = bySeason[lang] ?? bySeason['en']!;
  return FarmTip(pair[0], pair[1]);
}

/// region → season → language → [title, body]
const Map<String, Map<String, Map<String, List<String>>>> _tips = {
  // ---------------- Western Maharashtra ----------------
  'Western Maharashtra': {
    'kharif': {
      'en': [
        'Check soybean pods for borer now',
        'The second half of Kharif is when pod borer appears. Ten minutes of '
            'looking today can save the pods.',
      ],
      'mr': [
        'सोयाबीनच्या शेंगा तपासा',
        'खरिपाच्या उत्तरार्धात शेंगा पोखरणारी अळी येते. आज दहा मिनिटे पाहणी '
            'केल्यास शेंगा वाचू शकतात.',
      ],
      'hi': [
        'सोयाबीन की फलियाँ जाँचें',
        'खरीफ के दूसरे हिस्से में फली छेदक कीट आता है. आज दस मिनट की जाँच '
            'फलियाँ बचा सकती है.',
      ],
    },
    'rabi': {
      'en': [
        'Watch gram for pod borer moths',
        'Cool weather brings the moth into flowering gram. Walk the field in the '
            'morning and look at the flowers, not just the leaves.',
      ],
      'mr': [
        'हरभऱ्यावर घाटे अळीकडे लक्ष द्या',
        'थंडीत फुलोऱ्यातील हरभऱ्यावर पतंग येतो. सकाळी शेतात फेरी मारा आणि '
            'पानांबरोबर फुलेही पहा.',
      ],
      'hi': [
        'चने में फली छेदक पर नज़र रखें',
        'ठंड में फूल आते चने पर पतंगा आता है. सुबह खेत में घूमें और पत्तों के '
            'साथ फूल भी देखें.',
      ],
    },
    'summer': {
      'en': [
        'Mulch pomegranate basins before peak heat',
        'Dry leaves or cane trash around the basin keeps the soil cool and cuts '
            'how often you need to water.',
      ],
      'mr': [
        'उन्हाळ्यापूर्वी डाळिंबाच्या आळ्यात आच्छादन करा',
        'आळ्याभोवती पाला किंवा उसाचे पाचट टाकल्यास जमीन थंड राहते आणि पाणी '
            'देण्याचे प्रमाण कमी होते.',
      ],
      'hi': [
        'गर्मी से पहले अनार के थालों में मल्चिंग करें',
        'थाले के आसपास सूखी पत्तियाँ या गन्ने की पत्ती डालने से मिट्टी ठंडी '
            'रहती है और पानी कम लगता है.',
      ],
    },
  },

  // ---------------- North Maharashtra ----------------
  'North Maharashtra': {
    'kharif': {
      'en': [
        'Drain water from the onion nursery',
        'Standing water in the nursery rots the seedlings. Open the channel now, '
            'and check the leaf tips for thrips damage.',
      ],
      'mr': [
        'कांद्याच्या रोपवाटिकेतील पाणी काढा',
        'रोपवाटिकेत पाणी साचल्यास रोपे कुजतात. आजच पाट मोकळा करा आणि पानांच्या '
            'टोकांवर फुलकिड्यांची नासाडी पहा.',
      ],
      'hi': [
        'प्याज़ की नर्सरी से पानी निकालें',
        'नर्सरी में पानी रुकने से पौधे गलते हैं. आज ही नाली खोलें और पत्तों के '
            'सिरों पर थ्रिप्स का नुकसान देखें.',
      ],
    },
    'rabi': {
      'en': [
        'Rabi onion wants steady water, not heavy water',
        'Little and often builds the bulb. One big irrigation after a dry spell '
            'splits it.',
      ],
      'mr': [
        'रब्बी कांद्याला नियमित पाणी द्या, जास्त नको',
        'थोडे थोडे आणि नियमित पाणी दिल्यास कांदा चांगला पोसतो. कोरडे गेल्यावर '
            'एकदम भरपूर पाणी दिल्यास कांदा फुटतो.',
      ],
      'hi': [
        'रबी प्याज़ को नियमित पानी दें, ज़्यादा नहीं',
        'थोड़ा-थोड़ा और नियमित पानी कंद बढ़ाता है. सूखे के बाद एक बार भारी '
            'सिंचाई कंद फाड़ देती है.',
      ],
    },
    'summer': {
      'en': [
        'Cover banana bunches against the sun',
        'A dry banana leaf tied over the bunch prevents sunburn on the fruit and '
            'costs nothing.',
      ],
      'mr': [
        'केळीचे घड उन्हापासून झाकून घ्या',
        'घडावर केळीचे वाळलेले पान बांधल्यास फळ उन्हाने काळे पडत नाही — आणि खर्च '
            'काहीच नाही.',
      ],
      'hi': [
        'केले के घौद को धूप से ढकें',
        'घौद पर केले का सूखा पत्ता बाँधने से फल धूप से नहीं झुलसता, और खर्च कुछ '
            'भी नहीं.',
      ],
    },
  },

  // ---------------- Marathwada ----------------
  'Marathwada': {
    'kharif': {
      'en': [
        'Check cotton squares and bolls weekly',
        'Pink bollworm hides inside. Open a few bolls from different parts of the '
            'field — the edges first, they are hit earliest.',
      ],
      'mr': [
        'कापसाची पाती आणि बोंडे आठवड्याला तपासा',
        'गुलाबी बोंड अळी बोंडाच्या आत लपते. शेताच्या वेगवेगळ्या भागातील काही '
            'बोंडे फोडून पहा — आधी कडेची, तिथे प्रादुर्भाव लवकर होतो.',
      ],
      'hi': [
        'कपास की डोडी और बॉल हर हफ़्ते जाँचें',
        'गुलाबी सुंडी बॉल के अंदर छिपती है. खेत के अलग-अलग हिस्सों से कुछ बॉल '
            'तोड़कर देखें — पहले किनारे के, वहाँ पहले लगती है.',
      ],
    },
    'rabi': {
      'en': [
        'Sow rabi jowar without delay',
        'Rabi jowar lives on the moisture already stored in the soil. Every week '
            'you wait, there is less of it left.',
      ],
      'mr': [
        'रब्बी ज्वारीची पेरणी उशीर न करता करा',
        'रब्बी ज्वारी जमिनीत साठलेल्या ओलाव्यावर येते. उशीर होईल तसा तो ओलावा '
            'कमी होत जातो.',
      ],
      'hi': [
        'रबी ज्वार की बुवाई देर किए बिना करें',
        'रबी ज्वार मिट्टी में जमा नमी पर होती है. जितनी देर होगी, उतनी नमी कम '
            'बचेगी.',
      ],
    },
    'summer': {
      'en': [
        'Repair your field bunds before the rains',
        'Summer is the only time bunds can be built dry. A good bund holds both '
            'soil and water when the first heavy rain comes.',
      ],
      'mr': [
        'पावसापूर्वी बांध दुरुस्त करा',
        'बांध कोरड्यात बांधण्याची वेळ फक्त उन्हाळाच. चांगला बांध पहिल्या मोठ्या '
            'पावसात माती आणि पाणी दोन्ही अडवतो.',
      ],
      'hi': [
        'बारिश से पहले खेत की मेड़ सुधारें',
        'मेड़ सूखे में बाँधने का समय गर्मी ही है. अच्छी मेड़ पहली तेज़ बारिश '
            'में मिट्टी और पानी दोनों रोकती है.',
      ],
    },
  },

  // ---------------- Vidarbha ----------------
  'Vidarbha': {
    'kharif': {
      'en': [
        'Open a few cotton bolls and look inside',
        'Pink bollworm does its damage out of sight. Checking every week is the '
            'only way to catch it while it can still be stopped.',
      ],
      'mr': [
        'कापसाची काही बोंडे फोडून आतून पहा',
        'गुलाबी बोंड अळी नजरेआड नुकसान करते. आठवड्याला तपासणी हाच तो थांबवण्याचा '
            'एकमेव मार्ग.',
      ],
      'hi': [
        'कपास के कुछ बॉल तोड़कर अंदर देखें',
        'गुलाबी सुंडी छिपकर नुकसान करती है. हर हफ़्ते जाँच ही उसे रोकने का एक '
            'तरीका है.',
      ],
    },
    'rabi': {
      'en': [
        'Watch wheat for yellow rust in damp cool weather',
        'Look at the lower leaves for yellow powder that rubs off on your finger. '
            'Early is much easier than late.',
      ],
      'mr': [
        'दमट थंडीत गव्हावर तांबेऱ्याकडे लक्ष द्या',
        'खालच्या पानांवर बोटाला लागणारी पिवळी भुकटी दिसते का पहा. लवकर लक्षात '
            'आले तर आवरणे सोपे.',
      ],
      'hi': [
        'नम ठंड में गेहूँ पर पीला रतुआ देखें',
        'नीचे के पत्तों पर उँगली में लगने वाला पीला चूर्ण दिखता है क्या, देखें. '
            'जल्दी पकड़ में आए तो सँभालना आसान है.',
      ],
    },
    'summer': {
      'en': [
        'Give orange trees light water more often',
        'In peak heat, small frequent watering keeps the fruit on the tree. Long '
            'gaps followed by heavy water make it drop.',
      ],
      'mr': [
        'संत्र्याला थोडे पाणी पण वारंवार द्या',
        'कडक उन्हात थोडे थोडे पण वारंवार पाणी दिल्यास फळगळ थांबते. मोठा खाडा '
            'आणि नंतर भरपूर पाणी दिल्यास फळे गळतात.',
      ],
      'hi': [
        'संतरे को थोड़ा पानी पर बार-बार दें',
        'तेज़ गर्मी में थोड़ा-थोड़ा पर बार-बार पानी फल टिकाए रखता है. लंबा अंतराल '
            'और फिर भारी पानी फल गिरा देता है.',
      ],
    },
  },

  // ---------------- Konkan ----------------
  'Konkan': {
    'kharif': {
      'en': [
        'Keep rice bunds strong and let extra water out',
        'Konkan rain comes hard. A bund that holds and a channel that drains are '
            'worth more than anything you can spray.',
      ],
      'mr': [
        'भाताचे बांध मजबूत ठेवा आणि जास्तीचे पाणी काढा',
        'कोकणात पाऊस जोरात येतो. टिकणारा बांध आणि पाणी वाहून जाणारा पाट कोणत्याही '
            'फवारणीपेक्षा जास्त उपयोगी.',
      ],
      'hi': [
        'धान की मेड़ मज़बूत रखें और अतिरिक्त पानी निकालें',
        'कोंकण में बारिश तेज़ आती है. टिकने वाली मेड़ और पानी निकालने वाली नाली '
            'किसी छिड़काव से ज़्यादा काम की है.',
      ],
    },
    'rabi': {
      'en': [
        'Watch mango flowering closely now',
        'This is when hopper and powdery mildew decide your crop. Look at the '
            'flower panicles, not the leaves.',
      ],
      'mr': [
        'आंब्याच्या मोहोराकडे आता बारकाईने लक्ष द्या',
        'तुडतुडे आणि भुरी रोग याच वेळी पीक ठरवतात. पानांकडे नको, मोहोराकडे पहा.',
      ],
      'hi': [
        'आम के बौर पर अब ध्यान दें',
        'भुनगा और चूर्णिल आसिता इसी समय फ़सल तय करते हैं. पत्तों को नहीं, बौर को '
            'देखें.',
      ],
    },
    'summer': {
      'en': [
        'Harvest mango in the cool morning',
        'Fruit picked in the afternoon heat spoils faster and travels badly. Pick '
            'early, keep it in the shade.',
      ],
      'mr': [
        'आंबा सकाळच्या गारव्यात काढा',
        'दुपारच्या उन्हात काढलेला आंबा लवकर खराब होतो आणि वाहतुकीत टिकत नाही. '
            'सकाळी काढा, सावलीत ठेवा.',
      ],
      'hi': [
        'आम सुबह की ठंडक में तोड़ें',
        'दोपहर की गर्मी में तोड़ा आम जल्दी खराब होता है और ढुलाई में टिकता नहीं. '
            'सुबह तोड़ें, छाया में रखें.',
      ],
    },
  },
};
