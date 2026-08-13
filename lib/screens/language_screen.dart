import 'package:flutter/material.dart';

import '../data/app_language.dart';
import '../theme/app_colors.dart';
import 'district_screen.dart';

/// Language selection — the first real decision the farmer makes.
///
/// Structure follows the reference app Shruti chose: a title and subtitle at
/// the top, white rounded cards with a radio circle on the right, and one
/// full-width Continue button pinned to the bottom.
///
/// Adapted for KrishiMind:
///  * three languages, not seven
///  * each language is written once, in its own script
///  * the Continue button is written in whichever language is selected, so the
///    farmer sees the app change into their language before they even press it
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int _selected = defaultLanguageIndex;

  void _continue() {
    final chosen = appLanguages[_selected];
    // push, NOT pushReplacement. Keeping this screen underneath is what lets
    // the district screen offer a working "back" — the farmer can change their
    // mind about the language without restarting the app.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DistrictScreen(language: chosen)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A very soft green wash at the top fading into white. It stops the
      // screen looking like a blank sheet of paper, without adding clutter.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9F5EA), Colors.white],
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.035),

                    // ---- App emblem ----
                    // Repeating the emblem the farmer just saw on the splash
                    // makes the two screens feel like one app rather than two
                    // unrelated pages. It also fills the top of the screen so
                    // the layout doesn't look empty with only three languages.
                    Image.asset(
                      'assets/branding/emblem.png',
                      height: (constraints.maxHeight * 0.11).clamp(64.0, 96.0),
                      filterQuality: FilterQuality.high,
                    ),

                    SizedBox(height: constraints.maxHeight * 0.02),

                    // ---- Title ----
                    const Text(
                      'Select Your Language',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ---- Subtitle, in all three languages ----
                    // Deliberately trilingual: at this moment we do not yet
                    // know which one the farmer reads.
                    const Text(
                      'भाषा निवडा  ·  भाषा चुनें  ·  Choose a language',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: 13.5,
                        height: 1.45,
                        color: Color(0xFF6F7C72),
                      ),
                    ),

                    SizedBox(height: constraints.maxHeight * 0.045),

                    // ---- The three option cards ----
                    // Built from the list, not written out three times. Add a
                    // fourth language to app_language.dart and it appears here
                    // automatically.
                    ...List.generate(appLanguages.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _LanguageCard(
                          language: appLanguages[index],
                          isSelected: _selected == index,
                          onTap: () => setState(() => _selected = index),
                        ),
                      );
                    }),

                    // Pushes the button to the bottom of the screen.
                    const Spacer(),

                    // ---- Continue ----
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _continue,
                        // The label is in the selected language, and changes
                        // the instant a different card is tapped.
                        child: Text(
                          appLanguages[_selected].continueLabel,
                          style: const TextStyle(
                            fontFamily: 'NotoSansDevanagari',
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// One white card in the list.
///
/// Pulled out into its own small widget on purpose. When a piece of UI repeats,
/// give it a name — the screen above stays readable, and the card can be
/// changed in one place.
class _LanguageCard extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        // InkWell gives the ripple when tapped — free feedback that the tap
        // registered, which matters on cheap phones that can feel laggy.
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          // Animated, so selection glides rather than snapping. 180ms is the
          // sweet spot: noticeable, never slow.
          duration: const Duration(milliseconds: 180),
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? AppColors.accent : const Color(0xFFE2E9E3),
              width: isSelected ? 2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.16)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Just the language's own name, written once, in its own script.
              // The English translation underneath was removed — "मराठी /
              // Marathi" is the same word twice, and for a farmer who reads
              // Devanagari the second line is noise. Anyone looking for their
              // language recognises it by its own script.
              Expanded(
                child: Text(
                  language.nativeName,
                  style: const TextStyle(
                    fontFamily: 'NotoSansDevanagari',
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
              ),

              // ---- The radio circle ----
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accent
                        : const Color(0xFFC6D0C8),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AnimatedScale(
                    // The inner dot springs in when selected — the same idea as
                    // the ✓ in the camera tutorial: success grows.
                    scale: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
