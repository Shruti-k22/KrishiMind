/// One answer from the AI, broken into the four parts we agreed on.
///
/// The AI is forced to return JSON in exactly this shape (see gemini_service),
/// which is why the screen can draw a proper card with headings instead of
/// dumping a paragraph of text. Structure is what makes it look designed.
class Advice {
  /// What the problem most likely is. One short line — this is the headline.
  final String problem;

  /// Why it happened. Two sentences at most. This is the part that teaches the
  /// farmer something, and it is what separates an advisor from a search engine.
  final String why;

  /// What to do now. Each item is one action, in order.
  final List<String> steps;

  /// How sure the AI is. Drives the badge colour and whether we push the farmer
  /// towards a real expert.
  final AdviceConfidence confidence;

  /// True when the AI itself says a human should look at this.
  final bool needExpert;

  /// True when the question had nothing to do with farming. We then show a
  /// gentle nudge instead of a fake diagnosis.
  final bool offTopic;

  const Advice({
    required this.problem,
    required this.why,
    required this.steps,
    required this.confidence,
    required this.needExpert,
    required this.offTopic,
  });

  /// Builds an Advice from the JSON the model returns.
  ///
  /// Every field is read defensively. Even with a forced schema, a missing or
  /// oddly-typed value must never crash the screen — the farmer would just see
  /// a dead app and have no idea why.
  factory Advice.fromJson(Map<String, dynamic> j) {
    final rawSteps = j['steps'];
    return Advice(
      problem: (j['problem'] as String?)?.trim() ?? '',
      why: (j['why'] as String?)?.trim() ?? '',
      steps: rawSteps is List
          ? rawSteps
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : const [],
      confidence: _confidenceFrom(j['confidence'] as String?),
      needExpert: j['needExpert'] == true,
      offTopic: j['offTopic'] == true,
    );
  }

  static AdviceConfidence _confidenceFrom(String? s) {
    switch (s) {
      case 'high':
        return AdviceConfidence.high;
      case 'low':
        return AdviceConfidence.low;
      default:
        return AdviceConfidence.medium;
    }
  }

  /// Low confidence always sends the farmer to an expert, whatever the AI said.
  /// We decide this here rather than trusting the model to be humble.
  bool get shouldShowExpert => needExpert || confidence == AdviceConfidence.low;

  /// Does this answer talk about spraying or chemicals?
  ///
  /// If it does, the screen adds the "never guess the quantity" warning. We check
  /// the words rather than asking the model to tell us, because the warning is
  /// too important to depend on the model remembering to raise a flag.
  bool get mentionsChemical {
    final haystack = '$problem $why ${steps.join(' ')}'.toLowerCase();
    const markers = [
      // English
      'spray', 'pesticide', 'insecticide', 'fungicide', 'chemical', 'dose',
      'fertiliser', 'fertilizer',
      // Marathi
      'फवारणी', 'औषध', 'कीटकनाशक', 'बुरशीनाशक', 'खत', 'प्रमाण',
      // Hindi
      'छिड़काव', 'दवा', 'कीटनाशक', 'फफूंदनाशक', 'उर्वरक', 'मात्रा',
    ];
    for (final m in markers) {
      if (haystack.contains(m)) return true;
    }
    return false;
  }
}

enum AdviceConfidence { high, medium, low }

/// One line in the chat. Either something the farmer said, or an answer.
class ChatTurn {
  final bool fromFarmer;

  /// The farmer's question. Empty for AI turns.
  final String question;

  /// The AI's answer. Null for farmer turns, and null while it is still loading.
  final Advice? advice;

  /// Set when the request failed, so the bubble can show a retry.
  final String? error;

  const ChatTurn.farmer(this.question)
    : fromFarmer = true,
      advice = null,
      error = null;

  const ChatTurn.answer(this.advice)
    : fromFarmer = false,
      question = '',
      error = null;

  const ChatTurn.failed(this.error)
    : fromFarmer = false,
      question = '',
      advice = null;
}
