import 'package:flutter/material.dart';

/// Every colour in KrishiMind lives here and nowhere else.
///
/// Why: if a colour is written directly inside a screen, then changing it later
/// means hunting through every file. Defining them once means one edit changes
/// the whole app. This is the single most useful habit to build early.
///
/// These values were sampled directly from Shruti's own logo artwork, so the
/// app and the logo can never drift apart.
class AppColors {
  AppColors._(); // stops anyone creating an instance of this class by mistake

  /// Dark forest green — the "Krishi" half of the wordmark.
  /// Use for text, headings, and anything that must be easy to read.
  static const Color primary = Color(0xFF034720);

  /// Bright leaf green — the "Mind" half of the wordmark.
  /// Use for buttons and anything the farmer should tap.
  static const Color accent = Color(0xFF4B9824);

  /// Golden wheat tone from the icon. Small accents and badges only.
  static const Color wheat = Color(0xFFF0B429);

  /// The app's background. White is what will make it look professional.
  static const Color background = Color(0xFFFFFFFF);

  /// A very soft green tint, for panels that need to sit apart from white.
  static const Color tintedPanel = Color(0xFFE8F5E9);
}
