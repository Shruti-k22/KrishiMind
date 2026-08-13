/// The tagline shown under the wordmark on the splash screen.
///
/// It is kept as a plain list on purpose. Shruti raised the point herself:
/// the cycling animation only works because there are exactly three languages.
/// If the app ever supports ten Indian languages, cycling through all of them
/// would be absurd — so this list is the single place that decides what cycles.
/// Switching the behaviour off later means changing this file, not redesigning
/// the splash screen.
///
/// Order is deliberate: English first (a first-time farmer has not chosen a
/// language yet), then Hindi, ending on Marathi — so the last line left on
/// screen is the home state's language.
const List<String> splashTaglines = [
  'Your Smart Farming Advisor', // English
  'खेती का स्मार्ट सलाहकार', // Hindi
  'शेतीचा स्मार्ट सल्लागार', // Marathi
];

/// How long each tagline stays on screen before crossfading to the next.
const Duration taglineHold = Duration(milliseconds: 700);
