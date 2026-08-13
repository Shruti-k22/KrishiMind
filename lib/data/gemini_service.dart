import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../secrets.dart';
import 'advice.dart';
import 'districts.dart';
import 'weather.dart';

/// Talks to Google's Gemini API.
///
/// Two design decisions worth understanding, because they are the reason the
/// answers look good and stay safe:
///
/// 1. **We force the model to reply in JSON.** `responseSchema` tells Gemini the
///    exact shape it must return. Without this you get a paragraph of prose and
///    the app can only dump it on screen. With it, we get labelled fields and
///    can draw a real card — headline, reason, numbered steps.
///
/// 2. **The model is told what it must not do.** It is forbidden from inventing
///    pesticide doses. A wrong dose does not produce a wrong answer, it produces
///    a dead crop and a farmer who has lost money. Doses will come later from
///    the verified CIB&RC data, never from the AI's imagination.
class GeminiService {
  GeminiService._();

  /// The free-tier model. Fast and cheap, which is what a chat needs.
  ///
  /// This one line is deliberately the only place a model name appears. We
  /// started on `gemini-2.5-flash` and Google returned 404 with "no longer
  /// available to new users" — retired models keep appearing in the model list,
  /// so listing them is not proof you may use them. Changing this single
  /// constant was the entire fix, which is the point of keeping it here.
  ///
  /// To check what your key can currently use, run in PowerShell:
  ///   (Invoke-RestMethod -Uri "https://generativelanguage.googleapis.com/v1beta/models"
  ///     -Headers @{"x-goog-api-key"=$k}).models | Select-Object -ExpandProperty name
  static const String _model = 'gemini-3.5-flash';

  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// How many past exchanges the model can see. Two, as agreed — enough for
  /// "which medicine is cheapest?" to make sense, small enough that the request
  /// never grows and eats the free quota.
  static const int _rememberedExchanges = 2;

  /// Asks a question and returns a structured answer.
  ///
  /// [history] is the conversation so far, oldest first. Only the last few turns
  /// are actually sent.
  static Future<GeminiOutcome> ask({
    required String question,
    required String langCode,
    required District district,
    required List<ChatTurn> history,
  }) async {
    if (!Secrets.hasGeminiKey) return GeminiOutcome.noKey();

    // The key goes in a header, not in the URL. Google's newer keys (the ones
    // starting "AQ.") expect this, and a key in a URL is a bad habit anyway —
    // URLs end up in server logs, browser history and error reports.
    final url = Uri.parse('$_endpoint/$_model:generateContent');

    final body = {
      'system_instruction': {
        'parts': [
          {'text': _systemInstruction(langCode: langCode, district: district)},
        ],
      },
      'contents': _buildContents(question: question, history: history),
      'generationConfig': {
        // Low temperature: we want a careful advisor, not a creative writer.
        'temperature': 0.4,
        'maxOutputTokens': 900,
        'responseMimeType': 'application/json',
        'responseSchema': _answerSchema,
      },
    };

    try {
      final res = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': Secrets.geminiApiKey,
            },
            body: jsonEncode(body),
          )
          // Generous compared with the weather call, because the model genuinely
          // takes a few seconds to think. Still bounded, so a dead connection
          // does not leave the farmer staring at dots forever.
          .timeout(const Duration(seconds: 30));

      // Temporary while we get this working: print exactly what Google said.
      // The farmer never sees this — it only appears in the flutter run
      // terminal. Remove once the answers are reliable.
      if (res.statusCode != 200) {
        debugPrint('=== GEMINI FAILED: HTTP ${res.statusCode} ===');
        debugPrint(res.body.length > 900 ? res.body.substring(0, 900) : res.body);
      }

      if (res.statusCode == 429) return GeminiOutcome.quotaExhausted();
      if (res.statusCode == 400 || res.statusCode == 403) {
        // Almost always a bad or restricted key.
        return GeminiOutcome.badKey(detail: 'HTTP ${res.statusCode}');
      }
      if (res.statusCode != 200) {
        return GeminiOutcome.failed(detail: 'HTTP ${res.statusCode}');
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;

      // Gemini can refuse to answer (safety filters). There is then no text.
      final candidates = decoded['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        return GeminiOutcome.failed();
      }

      final parts =
          (candidates.first as Map)['content']?['parts'] as List? ?? const [];
      if (parts.isEmpty) return GeminiOutcome.failed();

      final text = (parts.first as Map)['text'] as String?;
      if (text == null || text.trim().isEmpty) return GeminiOutcome.failed();

      // The schema guarantees valid JSON, but never trust a network response.
      final parsed = jsonDecode(text) as Map<String, dynamic>;
      return GeminiOutcome.ok(Advice.fromJson(parsed));
    } catch (e) {
      // No internet, timeout, or a response we could not read. All the same to
      // the farmer: it did not work, try again.
      debugPrint('=== GEMINI THREW: $e ===');
      return GeminiOutcome.failed(detail: e.runtimeType.toString());
    }
  }

  /// Builds the conversation array, trimmed to the last few exchanges.
  static List<Map<String, dynamic>> _buildContents({
    required String question,
    required List<ChatTurn> history,
  }) {
    final contents = <Map<String, dynamic>>[];

    // Walk backwards collecting complete question/answer pairs, then flip.
    final recent = <Map<String, dynamic>>[];
    var exchanges = 0;
    for (var i = history.length - 1; i >= 0; i--) {
      if (exchanges >= _rememberedExchanges) break;
      final turn = history[i];
      if (turn.fromFarmer) {
        recent.add({
          'role': 'user',
          'parts': [
            {'text': turn.question},
          ],
        });
        exchanges++;
      } else if (turn.advice != null) {
        // Send back a compact version of our own answer. The model does not need
        // the whole card again — the headline is enough to keep the thread.
        recent.add({
          'role': 'model',
          'parts': [
            {
              'text': jsonEncode({
                'problem': turn.advice!.problem,
                'steps': turn.advice!.steps,
              }),
            },
          ],
        });
      }
    }
    contents.addAll(recent.reversed);

    contents.add({
      'role': 'user',
      'parts': [
        {'text': question},
      ],
    });
    return contents;
  }

  /// The rules the model must follow. This is the most important text in the
  /// whole app — it is what makes the answers useful, local, and safe.
  static String _systemInstruction({
    required String langCode,
    required District district,
  }) {
    final region = findRegionForDistrict(district.id) ?? 'Maharashtra';
    final season = switch (currentSeason(DateTime.now())) {
      FarmingSeason.kharif => 'Kharif (monsoon sowing, June to October)',
      FarmingSeason.rabi => 'Rabi (winter sowing, November to February)',
      FarmingSeason.summer => 'Summer season (March to May)',
    };
    final language = switch (langCode) {
      'mr' => 'Marathi (मराठी), in Devanagari script',
      'hi' => 'Hindi (हिंदी), in Devanagari script',
      _ => 'simple English',
    };

    return '''
You are KrishiMind, a farming advisor for small farmers in Maharashtra, India.

THE FARMER
- District: ${district.en} (${district.mr})
- Agro-climatic region: $region
- Current season: $season
- Today: ${DateTime.now().toIso8601String().substring(0, 10)}

WRITE THE ANSWER IN: $language
Every field you return must be in that language. Do not mix languages, except
that a chemical's internationally-known name may stay in English.

WHO YOU ARE TALKING TO
Many of these farmers left school early. Use short sentences and everyday words.
Never use technical vocabulary without explaining it in the same sentence. Speak
with respect — never as if the farmer has been careless.

STAY LOCAL
Only give advice that fits Maharashtra: its crops, its pests, its soils, its
rainfall, this season. Do not give advice copied from other countries or other
climates. If a practice needs irrigation the farmer may not have, say so.

SAFETY RULES — THESE ARE ABSOLUTE
1. NEVER state a pesticide or fertiliser dose. No ml per litre, no grams per
   acre, no spray volumes. Not even approximately.
2. You may name an active ingredient generically when it is genuinely the
   standard treatment, but you must then tell the farmer to confirm the exact
   quantity at the Krishi Seva Kendra or with the Taluka Agriculture Officer.
3. Prefer non-chemical action first when it can actually work: removing affected
   parts, changing irrigation, trapping, spacing, timing.
4. If the question describes something serious spreading fast, or you are not
   confident, set needExpert to true. Being unsure and honest is correct
   behaviour, not failure.
5. Never claim certainty from a text description alone. A farmer cannot show you
   the plant here, so say "it looks most like" rather than "it is".

FORMAT RULES
- problem: one short line. The most likely cause, not a list of five maybes.
- why: at most two sentences explaining how this happens. Teach, briefly.
- steps: 3 to 5 items. Each is one action the farmer can do this week. Start with
  what to do first. No step may contain a dose.
- confidence: high only when the description is clear and typical. low when the
  description is vague, or several very different problems would fit.
- offTopic: true if the question is not about farming, crops, soil, livestock,
  weather for farming, or farm income. Then put a polite one-line redirect in
  problem, leave why empty, and leave steps empty.
''';
  }

  /// The exact JSON shape Gemini must return. Gemini uses a subset of the
  /// OpenAPI schema format, so types are written in capitals.
  static const Map<String, dynamic> _answerSchema = {
    'type': 'OBJECT',
    'properties': {
      'problem': {'type': 'STRING'},
      'why': {'type': 'STRING'},
      'steps': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      },
      'confidence': {
        'type': 'STRING',
        'enum': ['high', 'medium', 'low'],
      },
      'needExpert': {'type': 'BOOLEAN'},
      'offTopic': {'type': 'BOOLEAN'},
    },
    'required': [
      'problem',
      'why',
      'steps',
      'confidence',
      'needExpert',
      'offTopic',
    ],
    // Keeps the model generating in a sensible order, which also makes the
    // response arrive in the order we display it.
    'propertyOrdering': [
      'problem',
      'why',
      'steps',
      'confidence',
      'needExpert',
      'offTopic',
    ],
  };
}

/// What came back. Either an answer, or a specific reason it did not work —
/// specific, because "something went wrong" is useless to whoever has to fix it.
class GeminiOutcome {
  final Advice? advice;
  final GeminiError? error;

  /// A short technical note — an HTTP code or an exception type. Shown on screen
  /// only while we are still getting this working, so a failure can be diagnosed
  /// without guessing. Delete the on-screen part before submission.
  final String? detail;

  const GeminiOutcome._(this.advice, this.error, [this.detail]);

  factory GeminiOutcome.ok(Advice a) => GeminiOutcome._(a, null);
  factory GeminiOutcome.noKey() => const GeminiOutcome._(null, GeminiError.noKey);
  factory GeminiOutcome.badKey({String? detail}) =>
      GeminiOutcome._(null, GeminiError.badKey, detail);
  factory GeminiOutcome.quotaExhausted() =>
      const GeminiOutcome._(null, GeminiError.quotaExhausted);
  factory GeminiOutcome.failed({String? detail}) =>
      GeminiOutcome._(null, GeminiError.failed, detail);

  bool get isOk => advice != null;
}

enum GeminiError { noKey, badKey, quotaExhausted, failed }
