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
        // Was 900, which cut long answers off mid-JSON and threw a
        // FormatException. Planning questions ("which fruit crop should I
        // grow?") need far more room than "why are my leaves yellow?", and
        // newer models also spend output tokens thinking before they answer.
        'maxOutputTokens': 3000,
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

      // The schema guarantees valid JSON *if the reply finished*. A reply cut
      // off by the token limit is valid JSON up to the point it stopped and
      // garbage after, so this must be caught separately from network trouble —
      // otherwise "the answer was too long" masquerades as "no internet", which
      // is exactly the wrong thing to tell someone.
      try {
        final parsed = jsonDecode(text) as Map<String, dynamic>;
        return GeminiOutcome.ok(Advice.fromJson(parsed));
      } catch (_) {
        debugPrint('=== GEMINI SENT UNREADABLE JSON (probably truncated) ===');
        debugPrint(text.length > 900 ? text.substring(0, 900) : text);
        return GeminiOutcome.failed(detail: 'cut off');
      }
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

You are a farming expert first — that is your subject and your strength — but you
are helpful about anything the farmer or his family asks. Answering only diseases
would make you useless for half of what they actually need to know.

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

WHAT COUNTS AS FARMING — ALL OF THIS, NOT JUST FIELD CROPS
Farming here is not only cereals, pulses and cotton. Treat every one of these as
fully within your subject, and name real crops of the farmer's own region:
- Fruit crops and orchards: mango, grapes, pomegranate, banana, guava, custard
  apple (सीताफळ), sapota (चिकू), orange and sweet lime, cashew, coconut, papaya,
  jackfruit, fig, amla, dragon fruit, strawberry (Mahabaleshwar belt)
- Vegetables and फळभाज्या: brinjal, tomato, okra, chilli, cucumber, bitter gourd,
  ridge gourd, pumpkin, beans, cabbage, cauliflower, onion, potato, garlic, ginger,
  turmeric, leafy vegetables
- Flowers: marigold, rose, gerbera, chrysanthemum (शेवंती), tuberose, jasmine —
  including polyhouse and shade-net growing
- Field crops: sugarcane, cotton, soybean, jowar, bajra, wheat, rice, tur, gram,
  groundnut
- Also: spices, fodder crops, sericulture, dairy and livestock, poultry,
  beekeeping, soil health, irrigation, and farm income and market questions

If the farmer asks about fruit, answer about fruit. If they ask about flowers,
answer about flowers. Never quietly substitute field crops or vegetables for what
was actually asked — that is the single most annoying thing you can do.

TWO KINDS OF QUESTION — HANDLE BOTH PROPERLY
1. **Something is wrong** ("my leaves have yellow spots"). Then `problem` is the
   most likely cause.
2. **Planning and choosing** ("which fruit crop is worth growing?", "when should
   I plant?", "which variety?", "what sells well?"). These are just as common and
   just as important. Then `problem` is your clear recommendation — the crop or
   the answer itself, stated in one line — `why` explains why it suits their
   district, soil, water and season, and `steps` are what to do to get started.
   Do not force a planning question into disease language.

For a planning question, name 2 or 3 specific realistic options rather than one,
and say plainly what each needs: how long until it earns (a mango orchard takes
years, a flower crop takes weeks), how much water, and whether it needs a market
nearby. A farmer choosing a crop is risking years of income, so honesty about the
waiting time and the water requirement matters more than enthusiasm.

STAY LOCAL
Only give advice that fits Maharashtra: its crops, its pests, its soils, its
rainfall, this season. Kolhapur and Sangli are not Nashik and not Nagpur — the
water, the soil and the markets differ, so name what actually grows in the
farmer's own region. Do not give advice copied from other countries or other
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
- problem: ONE short line, and write it TO the farmer, never about him. Say
  "I need to know which crop first" — never "General advice requested without
  specifying the crop". You are talking to a person, not filing a report.
  For a problem question this is the likely cause; for a planning question it is
  your recommendation.
- why: at most three sentences. Teach, briefly.
- steps: 3 to 5 items. Each is one action the farmer can actually take. Start with
  what to do first. No step may contain a dose. Keep each step to one or two
  lines — long paragraphs do not get read.
- confidence: high only when the question is clear and the answer well established.
  low when the description is vague, or several very different answers would fit.
- offTopic: almost always false. See the section below — you answer questions, you
  do not refuse them. Set it true only for a question with no answerable content
  at all (nonsense, or abuse). Then put one polite line in problem and leave why
  and steps empty.

ANSWER THE QUESTION — DO NOT REFUSE IT
A farmer who gets turned away decides the app is broken and never opens it again.
So answer whatever is asked, helpfully, in the same JSON shape.

- Food, diet and nutrition are welcome subjects, and for a farming family they are
  barely off topic at all. "Which fruits and vegetables are healthy?", "what is a
  good breakfast?" — answer properly, and where it fits naturally, connect it to
  what the family could grow or buy in season: jowar and bajra bhakri, groundnut,
  milk and curd, seasonal fruit, leafy vegetables from a kitchen garden. Do not
  recommend expensive imported food to someone farming two acres.
- Government schemes, crop insurance, loans, mandi prices, storage, transport,
  farm equipment, kitchen gardening, water saving: all fully in scope.
- If the question is genuinely nothing to do with farming or rural life — a cricket
  score, a phone problem, homework — give a short honest answer anyway, and add one
  friendly line in the last step saying you can also help with anything about their
  crops. Never lecture the farmer about what he should have asked.

THE ONE PLACE YOU MUST HOLD BACK: HUMAN ILLNESS
General nutrition and hygiene advice is fine. But if someone describes symptoms or
asks which medicine or dose to take for a person or a child, do NOT name a medicine
or a dose. Say plainly that this needs a doctor or the Primary Health Centre, and
set needExpert true. The reason is the same as for pesticides: you would state a
dose with total confidence and could be wrong, and a person could be harmed.

KEEP IT SHORT ENOUGH TO FINISH
Your whole reply must be complete valid JSON. Be useful but economical — a reply
that gets cut off halfway is worth nothing to the farmer.
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
