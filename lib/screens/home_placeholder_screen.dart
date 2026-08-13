import 'package:flutter/material.dart';

import '../data/app_language.dart';
import '../data/app_prefs.dart';
import '../data/districts.dart';
import '../theme/app_colors.dart';
import 'splash_screen.dart';

/// TEMPORARY — stands in for the dashboard until we build it.
///
/// It proves two things: the language and district travelled here correctly,
/// and they were saved to the phone. The reset button exists so you can see the
/// setup flow again without uninstalling the app.
class HomePlaceholderScreen extends StatelessWidget {
  final AppLanguage language;
  final District district;

  const HomePlaceholderScreen({
    super.key,
    required this.language,
    required this.district,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = language.code == 'en';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/branding/emblem.png', height: 84),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tintedPanel,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '${language.nativeName}  ·  ${isEn ? district.en : district.mr}',
                    style: const TextStyle(
                      fontFamily: 'NotoSansDevanagari',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Dashboard comes next',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Saved on this phone.\nThe app will not ask again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF7B877E),
                  ),
                ),
                const SizedBox(height: 34),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                  ),
                  onPressed: () async {
                    await AppPrefs.clearAll();
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                    );
                  },
                  child: const Text('Reset and start over (testing only)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
