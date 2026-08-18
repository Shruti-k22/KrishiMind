import 'package:flutter/material.dart';

import '../data/strings.dart';
import '../data/weather.dart';
import '../theme/app_colors.dart';

/// Today plus the next three days, as four small tiles.
///
/// Today is filled dark green and the rest are white — so the eye lands on
/// today first and the others read as "what is coming". Four is the right
/// number: it fits one screen width without shrinking the text, and nobody plans
/// spraying two weeks out.
class ForecastRow extends StatelessWidget {
  final List<DayForecast> days;
  final String lang;

  const ForecastRow({super.key, required this.days, required this.lang});

  @override
  Widget build(BuildContext context) {
    // No forecast (offline, or the service left it out) means no row at all.
    // An empty box would look like something failed.
    if (days.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (var i = 0; i < days.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _DayTile(day: days[i], lang: lang, isToday: i == 0),
          ),
        ],
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  final DayForecast day;
  final String lang;
  final bool isToday;

  const _DayTile({
    required this.day,
    required this.lang,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final label = isToday
        ? S.todayLabel(lang)
        : S.weekdayShort(lang, day.date.weekday);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? AppColors.primary : const Color(0xFFDDEADF),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'NotoSansDevanagari',
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: isToday ? const Color(0xFFBFE3C6) : const Color(0xFF7B877E),
            ),
          ),
          const SizedBox(height: 3),
          Icon(
            weatherIcon(day.weatherCode),
            size: 16,
            color: _iconColour(day.weatherCode, isToday),
          ),
          const SizedBox(height: 3),
          Text(
            '${day.maxTempC.round()}°',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isToday ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            '${day.rainChance}%',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: isToday ? const Color(0xFF9FD3AA) : const Color(0xFF8FA095),
            ),
          ),
        ],
      ),
    );
  }

  Color _iconColour(int code, bool onDark) {
    if (onDark) return const Color(0xFFBFE3C6);
    if (code == 0 || code == 1) return AppColors.wheat; // sunny
    if (code >= 51) return const Color(0xFF4E8BC4); // wet
    return const Color(0xFF7E9187); // cloud
  }
}

/// Open-Meteo returns a WMO weather code. This turns it into an icon.
///
/// The ranges come from the WMO standard: 0–3 clear to cloudy, 45–48 fog,
/// 51–67 drizzle and rain, 71–77 snow, 80–82 showers, 95+ thunderstorm.
IconData weatherIcon(int code) {
  if (code == 0) return Icons.wb_sunny_rounded;
  if (code <= 2) return Icons.wb_cloudy_rounded;
  if (code <= 3) return Icons.cloud_rounded;
  if (code <= 48) return Icons.foggy;
  if (code <= 57) return Icons.grain_rounded;
  if (code <= 67) return Icons.water_drop_rounded;
  if (code <= 77) return Icons.ac_unit_rounded;
  if (code <= 82) return Icons.water_drop_rounded;
  if (code <= 86) return Icons.ac_unit_rounded;
  return Icons.thunderstorm_rounded;
}
