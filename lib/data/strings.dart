/// Every piece of text the app shows, in all three languages.
///
/// One method per phrase. A screen asks for a word by name and passes the
/// current language code — no screen ever contains a hard-coded sentence.
///
/// This is the whole reason the app can switch language without redesigning
/// anything: the layout stays identical, only the strings change. Adding a
/// fourth language later means adding a fourth entry to each map.
class S {
  S._();

  static String _pick(Map<String, String> m, String lang) =>
      m[lang] ?? m['en']!;

  // ---------------- District screen ----------------

  static String districtTitle(String lang) => _pick({
    'en': 'Select Your District',
    'mr': 'तुमचा जिल्हा निवडा',
    'hi': 'अपना ज़िला चुनें',
  }, lang);

  static String districtSubtitle(String lang) => _pick({
    'en': 'So we can show problems from your area',
    'mr': 'जेणेकरून आम्ही तुमच्या भागातील समस्या दाखवू शकू',
    'hi': 'ताकि हम आपके क्षेत्र की समस्याएँ दिखा सकें',
  }, lang);

  static String continueLabel(String lang) =>
      _pick({'en': 'Continue', 'mr': 'पुढे चला', 'hi': 'आगे बढ़ें'}, lang);

  // ---------------- Greeting ----------------

  static String greeting(String lang, int hour) {
    if (hour < 12) {
      return _pick({
        'en': 'Good morning',
        'mr': 'शुभ सकाळ',
        'hi': 'सुप्रभात',
      }, lang);
    }
    if (hour < 17) {
      return _pick({
        'en': 'Good afternoon',
        'mr': 'शुभ दुपार',
        'hi': 'नमस्कार',
      }, lang);
    }
    return _pick({
      'en': 'Good evening',
      'mr': 'शुभ संध्याकाळ',
      'hi': 'शुभ संध्या',
    }, lang);
  }

  // ---------------- Seasons ----------------

  static String seasonKharif(String lang) =>
      _pick({'en': 'Kharif season', 'mr': 'खरीप हंगाम', 'hi': 'खरीफ मौसम'}, lang);

  static String seasonRabi(String lang) =>
      _pick({'en': 'Rabi season', 'mr': 'रब्बी हंगाम', 'hi': 'रबी मौसम'}, lang);

  static String seasonSummer(String lang) => _pick({
    'en': 'Summer season',
    'mr': 'उन्हाळी हंगाम',
    'hi': 'गर्मी का मौसम',
  }, lang);

  // ---------------- Spraying advice ----------------

  static String sprayGood(String lang) => _pick({
    'en': 'Good day for spraying',
    'mr': 'फवारणीसाठी चांगला दिवस',
    'hi': 'छिड़काव के लिए अच्छा दिन',
  }, lang);

  static String sprayRain(String lang) => _pick({
    'en': 'Rain likely — avoid spraying',
    'mr': 'पाऊस येऊ शकतो — फवारणी टाळा',
    'hi': 'बारिश हो सकती है — छिड़काव न करें',
  }, lang);

  static String sprayWind(String lang) => _pick({
    'en': 'Too windy — avoid spraying',
    'mr': 'वारा जास्त — फवारणी टाळा',
    'hi': 'तेज़ हवा — छिड़काव न करें',
  }, lang);

  // ---------------- The three ways to ask ----------------

  // Labels are deliberately plain. "Diagnose", "Analyse" and "निदान" are the
  // professional words, but a farmer who does not recognise a word will not tap
  // the button — and an untapped button is a failed design. The precise
  // agricultural language belongs in the answer, not on the buttons.
  static String askByVoice(String lang) =>
      _pick({'en': 'Ask by voice', 'mr': 'बोलून विचारा', 'hi': 'बोलकर पूछें'}, lang);

  static String askByVoiceHint(String lang) => _pick({
    'en': 'Tap and speak in your language',
    'mr': 'दाबा आणि तुमच्या भाषेत बोला',
    'hi': 'दबाएँ और अपनी भाषा में बोलें',
  }, lang);

  // "Scan crop" says what the app does with the image, not what the phone does.
  // It also tells the farmer what to point the camera at, which quietly prevents
  // the commonest mistake: a photo of the whole field from ten feet away.
  static String askByPhoto(String lang) => _pick({
    'en': 'Scan crop',
    'mr': 'पीक स्कॅन करा',
    'hi': 'फ़सल स्कैन करें',
  }, lang);

  static String askByText(String lang) => _pick({
    'en': 'Ask a question',
    'mr': 'प्रश्न विचारा',
    'hi': 'सवाल पूछें',
  }, lang);

  // ---------------- Offline ----------------

  static String offlineNotice(String lang) => _pick({
    'en': 'No internet. You can still read the guide below.',
    'mr': 'इंटरनेट नाही. खालील माहिती तुम्ही वाचू शकता.',
    'hi': 'इंटरनेट नहीं है. नीचे दी गई जानकारी पढ़ सकते हैं.',
  }, lang);

  // ---------------- Forecast ----------------

  static String todayLabel(String lang) =>
      _pick({'en': 'TODAY', 'mr': 'आज', 'hi': 'आज'}, lang);

  /// Short weekday name. [weekday] is Dart's DateTime.weekday: 1 = Monday.
  static String weekdayShort(String lang, int weekday) {
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const mr = ['सोम', 'मंगळ', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'];
    const hi = ['सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'];
    final i = (weekday - 1).clamp(0, 6);
    switch (lang) {
      case 'mr':
        return mr[i];
      case 'hi':
        return hi[i];
      default:
        return en[i];
    }
  }

  // ---------------- This week on your farm ----------------

  static String thisWeek(String lang) => _pick({
    'en': 'This week on your farm',
    'mr': 'या आठवड्यात तुमच्या शेतात',
    'hi': 'इस हफ़्ते आपके खेत में',
  }, lang);

  // ---------------- Sections ----------------

  static String problemsInYourArea(String lang) => _pick({
    'en': 'Common in your area',
    'mr': 'तुमच्या भागात नेहमी आढळणारे',
    'hi': 'आपके क्षेत्र में आम',
  }, lang);

  static String seeAll(String lang) =>
      _pick({'en': 'See all', 'mr': 'सर्व पहा', 'hi': 'सभी देखें'}, lang);

  // ---------------- Bottom navigation ----------------

  static String navHome(String lang) =>
      _pick({'en': 'Home', 'mr': 'मुख्यपृष्ठ', 'hi': 'होम'}, lang);

  static String navGuide(String lang) =>
      _pick({'en': 'Guide', 'mr': 'माहिती', 'hi': 'जानकारी'}, lang);

  static String navHistory(String lang) =>
      _pick({'en': 'History', 'mr': 'मागील प्रश्न', 'hi': 'पिछले सवाल'}, lang);

  static String navProfile(String lang) =>
      _pick({'en': 'Profile', 'mr': 'प्रोफाइल', 'hi': 'प्रोफ़ाइल'}, lang);

  // ---------------- Placeholder / coming soon ----------------

  static String comingNext(String lang) => _pick({
    'en': 'Coming next',
    'mr': 'लवकरच येत आहे',
    'hi': 'जल्द आ रहा है',
  }, lang);

  // ---------------- Sign in ----------------

  static String signInTitle(String lang) => _pick({
    'en': 'Sign in',
    'mr': 'साइन इन करा',
    'hi': 'साइन इन करें',
  }, lang);

  static String signInWhy(String lang) => _pick({
    'en': 'Only needed to get your questions back on a new phone',
    'mr': 'नवीन फोनवर तुमचे प्रश्न परत मिळवण्यासाठीच आवश्यक',
    'hi': 'नए फ़ोन पर आपके सवाल वापस पाने के लिए ही ज़रूरी',
  }, lang);

  static String withGoogle(String lang) => _pick({
    'en': 'Continue with Google',
    'mr': 'Google ने पुढे जा',
    'hi': 'Google से आगे बढ़ें',
  }, lang);

  static String orLabel(String lang) =>
      _pick({'en': 'or', 'mr': 'किंवा', 'hi': 'या'}, lang);

  static String emailLabel(String lang) => _pick({
    'en': 'Enter your email',
    'mr': 'तुमचा ईमेल टाका',
    'hi': 'अपना ईमेल डालें',
  }, lang);

  static String passwordLabel(String lang) => _pick({
    'en': 'Create a password for KrishiMind',
    'mr': 'KrishiMind साठी पासवर्ड तयार करा',
    'hi': 'KrishiMind के लिए पासवर्ड बनाएँ',
  }, lang);

  static String passwordHelp(String lang) => _pick({
    'en':
        'Think of any new password. Do NOT type your Gmail password here.',
    'mr':
        'कोणताही नवीन पासवर्ड ठरवा. तुमचा Gmail चा पासवर्ड येथे टाकू नका.',
    'hi':
        'कोई भी नया पासवर्ड सोचें. अपना Gmail पासवर्ड यहाँ न डालें.',
  }, lang);

  static String changeEmail(String lang) =>
      _pick({'en': 'change', 'mr': 'बदला', 'hi': 'बदलें'}, lang);

  static String forgotPassword(String lang) => _pick({
    'en': 'Forgot password?',
    'mr': 'पासवर्ड विसरला?',
    'hi': 'पासवर्ड भूल गए?',
  }, lang);

  static String skipForNow(String lang) => _pick({
    'en': 'Skip for now',
    'mr': 'आता नको',
    'hi': 'अभी नहीं',
  }, lang);

  static String invalidEmail(String lang) => _pick({
    'en': 'Please enter a valid email',
    'mr': 'कृपया योग्य ईमेल टाका',
    'hi': 'कृपया सही ईमेल डालें',
  }, lang);

  static String shortPassword(String lang) => _pick({
    'en': 'Password must be at least 6 characters',
    'mr': 'पासवर्ड कमीत कमी ६ अक्षरांचा असावा',
    'hi': 'पासवर्ड कम से कम ६ अक्षरों का हो',
  }, lang);

  static String wrongPassword(String lang) => _pick({
    'en': 'Wrong password. Try again.',
    'mr': 'पासवर्ड चुकीचा आहे. पुन्हा प्रयत्न करा.',
    'hi': 'पासवर्ड गलत है. फिर कोशिश करें.',
  }, lang);

  static String accountCreated(String lang) => _pick({
    'en': 'Account created — you are signed in',
    'mr': 'खाते तयार झाले — तुम्ही साइन इन आहात',
    'hi': 'खाता बन गया — आप साइन इन हैं',
  }, lang);

  static String welcomeBack(String lang) => _pick({
    'en': 'Signed in',
    'mr': 'साइन इन झाले',
    'hi': 'साइन इन हो गए',
  }, lang);

  static String noInternetAuth(String lang) => _pick({
    'en': 'No internet. Sign in needs a connection.',
    'mr': 'इंटरनेट नाही. साइन इन करण्यासाठी इंटरनेट लागते.',
    'hi': 'इंटरनेट नहीं है. साइन इन के लिए इंटरनेट चाहिए.',
  }, lang);

  static String tooManyTries(String lang) => _pick({
    'en': 'Too many attempts. Please wait a little.',
    'mr': 'खूप वेळा प्रयत्न झाले. थोडा वेळ थांबा.',
    'hi': 'बहुत बार कोशिश हुई. थोड़ा रुकें.',
  }, lang);

  static String somethingWrong(String lang) => _pick({
    'en': 'Something went wrong. Try again.',
    'mr': 'काहीतरी चूक झाली. पुन्हा प्रयत्न करा.',
    'hi': 'कुछ गड़बड़ हुई. फिर कोशिश करें.',
  }, lang);

  static String resetSent(String lang) => _pick({
    'en': 'Reset link sent to your email',
    'mr': 'पासवर्ड बदलण्याची लिंक तुमच्या ईमेलवर पाठवली',
    'hi': 'पासवर्ड बदलने का लिंक आपके ईमेल पर भेजा',
  }, lang);

  static String signedInAs(String lang) =>
      _pick({'en': 'Signed in as', 'mr': 'साइन इन:', 'hi': 'साइन इन:'}, lang);

  static String signOut(String lang) => _pick({
    'en': 'Sign out',
    'mr': 'साइन आउट करा',
    'hi': 'साइन आउट करें',
  }, lang);

  // ---------------- Ask by text: the chat screen ----------------

  static String askTitle(String lang) => _pick({
    'en': 'Ask KrishiMind',
    'mr': 'KrishiMind ला विचारा',
    'hi': 'KrishiMind से पूछें',
  }, lang);

  static String askHint(String lang) => _pick({
    'en': 'Write your question here',
    'mr': 'तुमचा प्रश्न येथे लिहा',
    'hi': 'अपना सवाल यहाँ लिखें',
  }, lang);

  /// Shown on the empty chat, above the example questions.
  static String askOpening(String lang) => _pick({
    'en': 'What is troubling your crop?',
    'mr': 'तुमच्या पिकाला काय झाले आहे?',
    'hi': 'आपकी फ़सल को क्या हुआ है?',
  }, lang);

  static String askOpeningHelp(String lang) => _pick({
    'en': 'Write in your own words. Tell us the crop and what you can see.',
    'mr': 'तुमच्या शब्दांत लिहा. पीक कोणते आणि काय दिसते ते सांगा.',
    'hi': 'अपने शब्दों में लिखें. फ़सल कौन सी है और क्या दिख रहा है बताएँ.',
  }, lang);

  static String askExamplesTitle(String lang) => _pick({
    'en': 'For example',
    'mr': 'उदाहरणार्थ',
    'hi': 'उदाहरण के लिए',
  }, lang);

  /// Ready-made questions. They exist for a practical reason: a farmer facing an
  /// empty box often does not know how much to write. One tap shows the level of
  /// detail that gets a good answer.
  static List<String> askExamples(String lang) {
    switch (lang) {
      case 'mr':
        return const [
          'माझ्या कापसाच्या पानांवर पिवळे ठिपके दिसत आहेत',
          'ऊस लावण्याची योग्य वेळ कोणती?',
          'टोमॅटोची फुले गळून पडत आहेत, काय करावे?',
        ];
      case 'hi':
        return const [
          'मेरी कपास की पत्तियों पर पीले धब्बे दिख रहे हैं',
          'गन्ना लगाने का सही समय कौन सा है?',
          'टमाटर के फूल गिर रहे हैं, क्या करें?',
        ];
      default:
        return const [
          'Yellow spots are appearing on my cotton leaves',
          'When is the right time to plant sugarcane?',
          'My tomato flowers are dropping — what should I do?',
        ];
    }
  }

  static String thinking(String lang) => _pick({
    'en': 'Thinking about your field…',
    'mr': 'तुमच्या शेताचा विचार करत आहे…',
    'hi': 'आपके खेत के बारे में सोच रहे हैं…',
  }, lang);

  // ---- The parts of an answer ----

  static String answerWhy(String lang) => _pick({
    'en': 'Why this happens',
    'mr': 'हे का होते',
    'hi': 'ऐसा क्यों होता है',
  }, lang);

  static String answerSteps(String lang) => _pick({
    'en': 'What to do now',
    'mr': 'आता काय करावे',
    'hi': 'अब क्या करें',
  }, lang);

  static String answerExpertTitle(String lang) => _pick({
    'en': 'Better to ask an expert',
    'mr': 'तज्ज्ञांना विचारणे चांगले',
    'hi': 'विशेषज्ञ से पूछना बेहतर',
  }, lang);

  static String answerExpertBody(String lang) => _pick({
    'en':
        'This one is not clear from a description alone. Show the plant to your '
        'Taluka Agriculture Officer or the Krishi Seva Kendra.',
    'mr':
        'हे केवळ वर्णनावरून नक्की सांगता येत नाही. रोप तुमच्या तालुका कृषी '
        'अधिकाऱ्यांना किंवा कृषी सेवा केंद्रात दाखवा.',
    'hi':
        'यह सिर्फ़ बताने से पक्का नहीं होता. पौधा अपने तालुका कृषि अधिकारी को या '
        'कृषि सेवा केंद्र में दिखाएँ.',
  }, lang);

  static String confidenceHigh(String lang) => _pick({
    'en': 'Fairly sure',
    'mr': 'बऱ्यापैकी खात्री',
    'hi': 'काफ़ी हद तक पक्का',
  }, lang);

  static String confidenceMedium(String lang) => _pick({
    'en': 'Most likely',
    'mr': 'बहुधा हेच',
    'hi': 'ज़्यादा संभावना यही',
  }, lang);

  static String confidenceLow(String lang) => _pick({
    'en': 'Not sure',
    'mr': 'खात्री नाही',
    'hi': 'पक्का नहीं',
  }, lang);

  /// The dose warning that sits under every answer that names a chemical.
  static String doseWarning(String lang) => _pick({
    'en':
        'Never guess the quantity. Ask at the Krishi Seva Kendra before mixing '
        'any chemical.',
    'mr':
        'प्रमाण अंदाजाने ठरवू नका. कोणतेही औषध मिसळण्यापूर्वी कृषी सेवा '
        'केंद्रात विचारा.',
    'hi':
        'मात्रा अंदाज़ से तय न करें. कोई भी दवा मिलाने से पहले कृषि सेवा केंद्र '
        'में पूछें.',
  }, lang);

  // ---- When it does not work ----

  static String askFailed(String lang) => _pick({
    'en': 'Could not get an answer. Check your internet and try again.',
    'mr': 'उत्तर मिळाले नाही. इंटरनेट तपासा आणि पुन्हा प्रयत्न करा.',
    'hi': 'जवाब नहीं मिला. इंटरनेट जाँचें और फिर कोशिश करें.',
  }, lang);

  static String askQuotaOver(String lang) => _pick({
    'en': 'Too many questions right now. Please try again in a minute.',
    'mr': 'आत्ता खूप प्रश्न आले आहेत. एका मिनिटानंतर प्रयत्न करा.',
    'hi': 'अभी बहुत सवाल आ गए हैं. एक मिनट बाद कोशिश करें.',
  }, lang);

  static String retry(String lang) => _pick({
    'en': 'Try again',
    'mr': 'पुन्हा प्रयत्न करा',
    'hi': 'फिर कोशिश करें',
  }, lang);

  static String aiDisclaimer(String lang) => _pick({
    'en': 'AI can make mistakes — check with an expert',
    'mr': 'AI चुकू शकते — तज्ज्ञांचा सल्ला घ्या',
    'hi': 'AI गलती कर सकता है — विशेषज्ञ से सलाह लें',
  }, lang);
}
