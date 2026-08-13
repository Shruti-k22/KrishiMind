import 'package:flutter/material.dart';

import '../data/strings.dart';
import '../data/weather.dart';
import '../theme/app_colors.dart';

/// The rounded weather panel at the top of the dashboard.
///
/// Three pieces of information, in order of usefulness to a farmer:
///   1. the spraying advice  — the only line that tells him what to DO today
///   2. the farming season   — खरीप / रब्बी / उन्हाळी, which decides what to plant
///   3. the temperature      — nice to have, he can feel it himself
///
/// Most weather widgets put the number first because it's the easiest thing to
/// display. That's backwards for this audience.
class WeatherCard extends StatelessWidget {
  final WeatherInfo? weather;
  final bool loading;
  final String lang;
  final DateTime now;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.loading,
    required this.lang,
    required this.now,
  });

  String _seasonLabel() {
    switch (currentSeason(now)) {
      case FarmingSeason.kharif:
        return S.seasonKharif(lang);
      case FarmingSeason.rabi:
        return S.seasonRabi(lang);
      case FarmingSeason.summer:
        return S.seasonSummer(lang);
    }
  }

  ({String text, IconData icon, Color color}) _advice(WeatherInfo w) {
    switch (w.sprayAdvice) {
      case SprayAdvice.good:
        return (
          text: S.sprayGood(lang),
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF2E9E3E),
        );
      case SprayAdvice.rainComing:
        return (
          text: S.sprayRain(lang),
          icon: Icons.water_drop_rounded,
          color: const Color(0xFF2A7FC4),
        );
      case SprayAdvice.tooWindy:
        return (
          text: S.sprayWind(lang),
          icon: Icons.air_rounded,
          color: const Color(0xFFCC8A1A),
        );
    }
  }

  /// Open-Meteo's weather codes, reduced to the four cases worth showing.
  IconData _skyIcon(int code) {
    if (code >= 95) return Icons.thunderstorm_rounded;
    if (code >= 51) return Icons.grain_rounded; // drizzle or rain
    if (code >= 2) return Icons.cloud_rounded;
    return Icons.wb_sunny_rounded; // clear
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1F9F1), Color(0xFFE6F3E7)],
        ),
        border: Border.all(color: const Color(0xFFD9E8DB)),
      ),
      child: loading
          ? const SizedBox(
              height: 74,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.accent,
                  ),
                ),
              ),
            )
          : weather == null
          ? _offlineBody()
          : _weatherBody(weather!),
    );
  }

  Widget _weatherBody(WeatherInfo w) {
    final a = _advice(w);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_skyIcon(w.weatherCode), size: 34, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              '${w.temperatureC.round()}°',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1.0,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _seasonLabel(),
                style: const TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),
        const Divider(height: 1, color: Color(0xFFD9E8DB)),
        const SizedBox(height: 11),

        // The line that actually helps him decide something today.
        Row(
          children: [
            Icon(a.icon, size: 19, color: a.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                a.text,
                style: TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: a.color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _offlineBody() {
    return Row(
      children: [
        const Icon(
          Icons.cloud_off_rounded,
          size: 26,
          color: Color(0xFF9BA69E),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            S.offlineNotice(lang),
            style: const TextStyle(
              fontFamily: 'NotoSansDevanagari',
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6F7C72),
            ),
          ),
        ),
      ],
    );
  }
}
