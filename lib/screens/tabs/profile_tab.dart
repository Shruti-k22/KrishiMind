import 'package:flutter/material.dart';

import '../../data/app_language.dart';
import '../../data/app_prefs.dart';
import '../../data/auth_service.dart';
import '../../data/districts.dart';
import '../../theme/app_colors.dart';
import '../auth/sign_in_screen.dart';
import '../splash_screen.dart';

/// Profile — optional Google sign-in, and where language and district become
/// changeable later.
///
/// Login is never forced. Around half the target farmers cannot manage an
/// account, and the app has to work perfectly without one.
class ProfileTab extends StatefulWidget {
  final AppLanguage language;
  final District district;

  const ProfileTab({super.key, required this.language, required this.district});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  AppLanguage get language => widget.language;
  District get district => widget.district;

  @override
  Widget build(BuildContext context) {
    final en = language.code == 'en';
    final districtName = en ? district.en : district.mr;
    final user = AuthService.currentUser;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
        children: [
          // ---- Who this phone belongs to ----
          Center(
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tintedPanel,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 38,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user?.email ??
                      (en ? 'Not signed in' : 'साइन इन केलेले नाही'),
                  style: const TextStyle(
                    fontFamily: 'NotoSansDevanagari',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user != null
                      ? (en ? 'Signed in' : 'साइन इन झाले')
                      : (en
                            ? 'The app works fully without an account'
                            : 'खात्याशिवायही अ‍ॅप पूर्ण चालते'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'NotoSansDevanagari',
                    fontSize: 12.5,
                    color: Color(0xFF7B877E),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // ---- Current settings ----
          // Display only. Both are changed from the dashboard — the language
          // pill and the district line at the top. Offering the same action in
          // two places just makes the app feel bigger than it is.
          _Row(
            icon: Icons.translate_rounded,
            label: en ? 'Language' : 'भाषा',
            value: language.nativeName,
          ),
          const SizedBox(height: 10),
          _Row(
            icon: Icons.location_on_rounded,
            label: en ? 'District' : 'जिल्हा',
            value: districtName,
          ),

          const SizedBox(height: 26),

          // ---- Sign in (not built yet) ----
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: Color(0xFFDCE6DE), width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                if (user != null) {
                  await AuthService.signOut();
                  if (mounted) setState(() {});
                  return;
                }
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SignInScreen(language: language),
                  ),
                );
                // Refresh so the email appears straight after signing in.
                if (mounted) setState(() {});
              },
              icon: Icon(
                user != null ? Icons.logout_rounded : Icons.login_rounded,
                size: 19,
              ),
              label: Text(
                user != null
                    ? (en ? 'Sign out' : 'साइन आउट करा')
                    : (en ? 'Sign in' : 'साइन इन करा'),
                style: const TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            en
                ? 'Only needed to get your questions back on a new phone'
                : 'नवीन फोनवर तुमचे प्रश्न परत मिळवण्यासाठीच आवश्यक',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'NotoSansDevanagari',
              fontSize: 11.5,
              color: Color(0xFF9BA69E),
            ),
          ),

          const SizedBox(height: 34),
          const Divider(height: 1, color: Color(0xFFE6EDE7)),
          const SizedBox(height: 18),

          // ---- DEMO ONLY ----
          // Clears the saved language and district so the setup screens appear
          // again. This is how you show the whole app from the beginning without
          // uninstalling it. DELETE THIS BUTTON before submission or release.
          Text(
            'For demo / testing',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade800,
                side: BorderSide(color: Colors.orange.shade200, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              onPressed: () => _confirmReset(context),
              icon: const Icon(Icons.restart_alt_rounded, size: 19),
              label: const Text(
                'Show app from the beginning',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Asks first. A reset that fires on a single accidental tap during a live
  /// demo would be embarrassing.
  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start from the beginning?'),
        content: const Text(
          'The saved language and district will be cleared, so the app will ask '
          'for them again — exactly like a fresh install.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, restart'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    await AppPrefs.clearAll();
    if (!context.mounted) return;

    // Wipe every screen and go back to the splash, so it behaves exactly like
    // opening the app for the very first time.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }
}

/// One read-only line: icon, label, value.
///
/// It used to accept an optional onTap and show a chevron. Both were removed
/// once language and district became changeable from the dashboard instead —
/// a tappable-looking row that does nothing is worse than a plain one.
class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EDE7), width: 1.3),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.accent),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'NotoSansDevanagari',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6F7C72),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'NotoSansDevanagari',
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
