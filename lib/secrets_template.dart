/// TEMPLATE — this file IS committed to GitHub, on purpose.
///
/// secrets.dart is ignored by git, so anyone who clones this project will not
/// have one and the project will not compile. This template is the fix:
///
///   1. Copy this file and rename the copy to  secrets.dart
///   2. Get your own free key at https://aistudio.google.com/apikey
///   3. Paste it below.
///
/// This is the standard way open projects handle keys: the shape of the file is
/// public, the value inside it is not.
class Secrets {
  Secrets._();

  static const String geminiApiKey = 'PASTE_YOUR_OWN_FREE_KEY_HERE';

  static bool get hasGeminiKey =>
      geminiApiKey.trim().isNotEmpty &&
      geminiApiKey != 'PASTE_YOUR_OWN_FREE_KEY_HERE';
}
