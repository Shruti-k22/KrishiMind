import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_language.dart';
import '../data/app_prefs.dart';
import '../data/districts.dart';
import '../data/taglines.dart';
import '../theme/app_colors.dart';
import 'home_shell.dart';
import 'language_screen.dart';

/// KrishiMind splash screen.
///
/// The rules this screen follows, exactly as Shruti specified them:
///
///  * Background is fully white.
///  * The icon, the wordmark and the tagline all appear TOGETHER at the same
///    moment. Nothing waits its turn — a staggered entrance was rejected for
///    being too slow.
///  * While the group is still fading in, the tagline is ALREADY cycling
///    through English, Hindi, Marathi. The two animations overlap.
///  * The icon and wordmark are her own artwork, shown as images. They are
///    never re-drawn in a font, so the leaf on the "i" survives.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// "SingleTickerProviderStateMixin" is what lets this screen drive an animation.
// Think of it as giving the screen a clock to animate against.
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  Timer? _taglineTimer;
  int _taglineIndex = 0;

  @override
  void initState() {
    super.initState();

    // ---- The group entrance: one fade + one gentle scale, 600ms ----
    _entrance = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);

    // Starts at 0.94 (slightly small) and settles at 1.0 (full size).
    // Deliberately subtle: a big zoom would look like a game, not a tool.
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
    );

    // Both of these start on the very same line of code — that is what makes
    // them simultaneous rather than sequential.
    _entrance.forward();
    _startTaglineCycle();
  }

  void _startTaglineCycle() {
    // Advance the tagline every 700ms.
    _taglineTimer = Timer.periodic(taglineHold, (timer) {
      if (!mounted) return;

      final isLast = _taglineIndex >= splashTaglines.length - 1;

      if (isLast) {
        // The last tagline (Marathi) has had its time on screen. Stop, and move
        // on to the next screen.
        timer.cancel();
        _goToNextScreen();
        return;
      }

      setState(() => _taglineIndex++);
    });
  }

  Future<void> _goToNextScreen() async {
    if (!mounted) return;

    // This is the splash doing real work rather than just counting to two.
    // We check whether this phone has already been set up.
    final done = await AppPrefs.isSetupComplete();
    if (!mounted) return;

    Widget next;
    if (done) {
      // Returning farmer — skip the setup screens entirely. This is what makes
      // the app "never ask again".
      final lang = findLanguageByCode(await AppPrefs.getLanguage());
      final district = findDistrictById(await AppPrefs.getDistrict());
      if (!mounted) return;
      next = district == null
          ? const LanguageScreen()
          : HomeShell(language: lang, district: district);
    } else {
      // First time on this phone.
      next = const LanguageScreen();
    }

    // pushReplacement, not push: the farmer must never be able to press "back"
    // and land on the splash screen again.
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  void dispose() {
    // Always clean these up, or the animation and timer keep running in the
    // background after the screen is gone. This is a very common beginner leak.
    _taglineTimer?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // SafeArea keeps content clear of the notch and the gesture bar.
      body: SafeArea(
        // LayoutBuilder tells us the real space available on THIS phone, so
        // nothing is hard-coded to one screen size.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // Sizes are a fraction of screen width, then clamped so the app
            // still looks right on a tiny phone and on a tablet.
            final emblemSize = (width * 0.33).clamp(110.0, 190.0);
            final wordmarkWidth = (width * 0.58).clamp(190.0, 320.0);

            return Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nudges the whole stack slightly above the exact centre.
                      // Optically this reads as "centred"; true centre looks low.
                      SizedBox(height: constraints.maxHeight * 0.04),

                      // ---- 1. The emblem (her artwork, untouched) ----
                      Image.asset(
                        'assets/branding/emblem.png',
                        width: emblemSize,
                        height: emblemSize,
                        // Keeps the artwork crisp when scaled down.
                        filterQuality: FilterQuality.high,
                      ),

                      SizedBox(height: constraints.maxHeight * 0.025),

                      // ---- 2. The wordmark (her artwork, untouched) ----
                      Image.asset(
                        'assets/branding/wordmark.png',
                        width: wordmarkWidth,
                        filterQuality: FilterQuality.high,
                      ),

                      SizedBox(height: constraints.maxHeight * 0.022),

                      // ---- 3. The cycling tagline ----
                      // A fixed-height box so the layout never jumps when the
                      // text changes length between languages.
                      SizedBox(
                        height: 26,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          // Crossfade: the old line fades out as the new fades in.
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: Text(
                            splashTaglines[_taglineIndex],
                            // The ValueKey is what tells Flutter "this is a
                            // different line of text now, animate the change".
                            // Without it the text would swap with no fade.
                            key: ValueKey<int>(_taglineIndex),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              // Bundled font so Devanagari renders properly
                              // even with no internet.
                              fontFamily: 'NotoSansDevanagari',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
