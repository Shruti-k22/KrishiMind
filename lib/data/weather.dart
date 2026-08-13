import 'dart:convert';

import 'package:http/http.dart' as http;

import 'districts.dart';

/// The weather for the farmer's district, plus the one thing that actually
/// matters to him: whether today is a good day to spray.
///
/// Uses Open-Meteo, which is free and needs no API key and no account. We send
/// the district's coordinates — this is why we never needed GPS.
class WeatherInfo {
  final double temperatureC;
  final int weatherCode; // Open-Meteo's code for clear / cloudy / rain etc.
  final double windKmh;
  final int maxRainChance; // highest chance of rain in the next 12 hours, %

  const WeatherInfo({
    required this.temperatureC,
    required this.weatherCode,
    required this.windKmh,
    required this.maxRainChance,
  });

  /// The spraying verdict.
  ///
  /// Why this is the most useful line on the whole card: spraying before rain
  /// washes the chemical off the leaves. The farmer pays for the chemical, pays
  /// for the labour, and gets nothing. Strong wind does the same by blowing the
  /// spray away from the crop.
  SprayAdvice get sprayAdvice {
    if (maxRainChance >= 50) return SprayAdvice.rainComing;
    if (windKmh >= 20) return SprayAdvice.tooWindy;
    return SprayAdvice.good;
  }
}

enum SprayAdvice { good, rainComing, tooWindy }

/// The three farming seasons of Maharashtra.
///
/// Not "summer / winter" — those mean nothing agriculturally. Kharif, Rabi and
/// the summer season are what decide which crop goes in the ground.
enum FarmingSeason { kharif, rabi, summer }

FarmingSeason currentSeason(DateTime now) {
  final m = now.month;
  if (m >= 6 && m <= 10) return FarmingSeason.kharif; // monsoon sowing
  if (m >= 11 || m <= 2) return FarmingSeason.rabi; // winter sowing
  return FarmingSeason.summer; // March–May
}

class WeatherService {
  /// Fetches the weather. Returns null if there is no internet or the service
  /// is unreachable — the screen treats null as "offline" and carries on.
  static Future<WeatherInfo?> fetch(District district) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=${district.lat}&longitude=${district.lon}'
      '&current=temperature_2m,weather_code,wind_speed_10m'
      '&hourly=precipitation_probability'
      '&forecast_days=1&timezone=auto',
    );

    try {
      // A short timeout on purpose. A farmer on a weak rural connection should
      // see the screen quickly, not stare at a spinner for 30 seconds.
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final current = json['current'] as Map<String, dynamic>;

      // Look at the next 12 hours of rain chance and keep the highest.
      final probs =
          (json['hourly']?['precipitation_probability'] as List?) ?? const [];
      int maxRain = 0;
      for (var i = 0; i < probs.length && i < 12; i++) {
        final v = (probs[i] as num?)?.toInt() ?? 0;
        if (v > maxRain) maxRain = v;
      }

      return WeatherInfo(
        temperatureC: (current['temperature_2m'] as num).toDouble(),
        weatherCode: (current['weather_code'] as num).toInt(),
        windKmh: (current['wind_speed_10m'] as num).toDouble(),
        maxRainChance: maxRain,
      );
    } catch (_) {
      // Any failure — no internet, timeout, bad response — is simply "offline".
      return null;
    }
  }
}
