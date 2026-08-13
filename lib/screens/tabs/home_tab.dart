import 'package:flutter/material.dart';

import '../../data/app_language.dart';
import '../../data/districts.dart';
import '../../data/strings.dart';
import '../../data/weather.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ask_buttons.dart';
import '../../widgets/weather_card.dart';
import '../../data/app_prefs.dart';
import '../ask/text_ask_screen.dart';
import '../district_screen.dart';
import '../home_shell.dart';

/// The dashboard.
///
/// Order on screen, exactly as agreed with Shruti:
///   1. greeting + district
///   2. weather card (rounded rectangle, temperature, season, spraying advice)
///   3. the three ways to ask — voice first and full width, photo and text below
///   4. a small preview of common problems in their area
///
/// The full crop / season / disease library lives in the Guide tab, not here.
/// Keeping this screen short is what stops it looking cluttered.
class HomeTab extends StatefulWidget {
  final AppLanguage language;
  final District district;

  const HomeTab({super.key, required this.language, required this.district});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  WeatherInfo? _weather;
  bool _loading = true;

  String get _lang => widget.language.code;

  /// If the weather call failed there is no internet, so the AI buttons cannot
  /// work either. We get the offline check for free instead of adding another
  /// package for it.
  bool get _isOnline => _weather != null;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final w = await WeatherService.fetch(widget.district);
    if (!mounted) return;
    setState(() {
      _weather = w;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final districtName = _lang == 'en'
        ? widget.district.en
        : widget.district.mr;

    return SafeArea(
      child: RefreshIndicator(
        // Pull down to try the weather again — the natural gesture when a
        // farmer regains signal.
        color: AppColors.accent,
        onRefresh: _loadWeather,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          children: [
            // ---- Greeting + district ----
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.greeting(_lang, now.hour),
                        style: const TextStyle(
                          fontFamily: 'NotoSansDevanagari',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Tappable: tapping your district is how you change it.
                      // A back arrow would be wrong here — home is the first
                      // screen, there is nothing behind it. You change a
                      // setting by tapping the setting.
                      InkWell(
                        onTap: _changeDistrict,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                districtName,
                                style: const TextStyle(
                                  fontFamily: 'NotoSansDevanagari',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6F7C72),
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.expand_more_rounded,
                                size: 15,
                                color: Color(0xFF9BA69E),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Quick language switch. A farmer may reach the dashboard and
                // realise they would rather read English — making them dig into
                // Profile for that is too slow.
                _LanguageChip(
                  current: widget.language,
                  onPick: _changeLanguage,
                ),
                const SizedBox(width: 10),
                Image.asset('assets/branding/emblem.png', height: 42),
              ],
            ),

            const SizedBox(height: 16),

            // ---- Weather ----
            WeatherCard(
              weather: _weather,
              loading: _loading,
              lang: _lang,
              now: now,
            ),

            const SizedBox(height: 20),

            // ---- The three ways to ask ----
            AskButtons(
              lang: _lang,
              enabled: _isOnline,
              onVoice: () => _notReadyYet('voice'),
              onPhoto: () => _notReadyYet('image'),
              onText: _openTextAsk,
            ),

            const SizedBox(height: 24),

            // ---- Preview of the local library ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    S.problemsInYourArea(_lang),
                    style: const TextStyle(
                      fontFamily: 'NotoSansDevanagari',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  S.seeAll(_lang),
                  style: const TextStyle(
                    fontFamily: 'NotoSansDevanagari',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _PreviewRow(lang: _lang, district: widget.district),

            const SizedBox(height: 18),

            // ---- Honest disclaimer ----
            // Matters more here than in a houseplant app: wrong advice costs a
            // farmer money.
            Center(
              child: Text(
                S.aiDisclaimer(_lang),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 11,
                  color: Color(0xFF9BA69E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the district list. When a new district is chosen it saves and
  /// rebuilds the whole app frame with the new one, so the weather and the crop
  /// list update straight away.
  void _changeDistrict() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DistrictScreen(language: widget.language)),
    );
  }

  /// Changes language immediately and stays on the dashboard.
  ///
  /// Deliberately does NOT walk back through the district screen — the farmer
  /// already told us their district, and asking twice for something we know is
  /// the kind of small rudeness that makes an app feel clumsy.
  Future<void> _changeLanguage(AppLanguage picked) async {
    if (picked.code == widget.language.code) return;
    await AppPrefs.saveLanguage(picked.code);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            HomeShell(language: picked, district: widget.district),
      ),
      (route) => false,
    );
  }

  /// Opens the chat. Pushed on top of the dashboard rather than replacing it, so
  /// the back arrow returns the farmer exactly where they were.
  void _openTextAsk() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TextAskScreen(
          language: widget.language,
          district: widget.district,
        ),
      ),
    );
  }

  void _notReadyYet(String which) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$which — coming in the next step'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

/// Temporary preview cards.
///
/// Real photographs and disease names arrive with the data step. For now these
/// show the actual crops of the farmer's region, so the screen reads as real
/// rather than empty.
class _PreviewRow extends StatelessWidget {
  final String lang;
  final District district;

  const _PreviewRow({required this.lang, required this.district});

  static const Map<String, List<List<String>>> _cropsByRegion = {
    // region : [ [english, marathi], ... ]
    'Western Maharashtra': [
      ['Sugarcane', 'ऊस'],
      ['Grapes', 'द्राक्ष'],
      ['Pomegranate', 'डाळिंब'],
      ['Soybean', 'सोयाबीन'],
      ['Jowar', 'ज्वारी'],
    ],
    'North Maharashtra': [
      ['Onion', 'कांदा'],
      ['Banana', 'केळी'],
      ['Cotton', 'कापूस'],
      ['Grapes', 'द्राक्ष'],
    ],
    'Marathwada': [
      ['Cotton', 'कापूस'],
      ['Tur', 'तूर'],
      ['Jowar', 'ज्वारी'],
      ['Sugarcane', 'ऊस'],
      ['Bajra', 'बाजरी'],
    ],
    'Vidarbha': [
      ['Cotton', 'कापूस'],
      ['Soybean', 'सोयाबीन'],
      ['Orange', 'संत्रा'],
      ['Tur', 'तूर'],
      ['Wheat', 'गहू'],
    ],
    'Konkan': [
      ['Rice', 'भात'],
      ['Mango', 'आंबा'],
      ['Cashew', 'काजू'],
      ['Coconut', 'नारळ'],
    ],
  };

  @override
  Widget build(BuildContext context) {
    final region = findRegionForDistrict(district.id) ?? 'Western Maharashtra';
    final crops = _cropsByRegion[region] ?? const [];

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: crops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 11),
        itemBuilder: (context, i) {
          final name = lang == 'en' ? crops[i][0] : crops[i][1];
          return Container(
            width: 96,
            decoration: BoxDecoration(
              color: AppColors.tintedPanel,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFDCE8DD)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.eco_rounded,
                  size: 28,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'NotoSansDevanagari',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


/// The small language pill in the top-right of the dashboard.
///
/// Shows the current language, and opens a sheet with the three options. Kept
/// deliberately small — it is a setting, not a feature, and the screen is
/// already carrying a weather card and three buttons.
class _LanguageChip extends StatelessWidget {
  final AppLanguage current;
  final ValueChanged<AppLanguage> onPick;

  const _LanguageChip({required this.current, required this.onPick});

  /// Short label so the chip stays narrow: मरा / हिं / EN
  String get _short {
    switch (current.code) {
      case 'mr':
        return 'मराठी';
      case 'hi':
        return 'हिंदी';
      default:
        return 'EN';
    }
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE5DF),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'भाषा  ·  भाषा  ·  Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7B877E),
                ),
              ),
              const SizedBox(height: 14),
              for (final l in appLanguages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: l.code == current.code
                        ? AppColors.tintedPanel
                        : Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(13),
                      onTap: () {
                        Navigator.pop(ctx);
                        onPick(l);
                      },
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: l.code == current.code
                                ? AppColors.accent
                                : const Color(0xFFE6EDE7),
                            width: l.code == current.code ? 1.8 : 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.nativeName,
                                style: const TextStyle(
                                  fontFamily: 'NotoSansDevanagari',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (l.code == current.code)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.accent,
                                size: 21,
                              ),
                          ],
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tintedPanel,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDCE8DD)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.translate_rounded,
                size: 14,
                color: AppColors.accent,
              ),
              const SizedBox(width: 5),
              Text(
                _short,
                style: const TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Icon(
                Icons.expand_more_rounded,
                size: 15,
                color: Color(0xFF9BA69E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
