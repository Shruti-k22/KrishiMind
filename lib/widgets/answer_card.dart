import 'package:flutter/material.dart';

import '../data/advice.dart';
import '../data/strings.dart';
import '../theme/app_colors.dart';

/// One AI answer, drawn as a card.
///
/// The order on screen is the order we agreed: what the problem is, why it
/// happens, what to do now, and an expert route when the AI is not confident.
/// Each part gets its own visual weight, so a farmer who only reads the first
/// line still gets the most important information.
class AnswerCard extends StatelessWidget {
  final Advice advice;
  final String lang;

  const AnswerCard({super.key, required this.advice, required this.lang});

  @override
  Widget build(BuildContext context) {
    // A question that had nothing to do with farming gets a short, polite card
    // instead of a fake diagnosis. Pretending to answer would be worse than
    // admitting the question was outside our subject.
    if (advice.offTopic) {
      return _Shell(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: AppColors.accent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                advice.problem,
                style: const TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 14.5,
                  height: 1.45,
                  color: Color(0xFF44544A),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _Shell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Confidence badge ----
          // Sits above the headline on purpose. The farmer should know how much
          // to trust the line before reading it, not after.
          _ConfidenceBadge(confidence: advice.confidence, lang: lang),

          const SizedBox(height: 10),

          // ---- The headline: what it most likely is ----
          Text(
            advice.problem,
            style: const TextStyle(
              fontFamily: 'NotoSansDevanagari',
              fontSize: 17,
              height: 1.35,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),

          // ---- Why it happens ----
          if (advice.why.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionLabel(text: S.answerWhy(lang), icon: Icons.help_outline_rounded),
            const SizedBox(height: 7),
            Text(
              advice.why,
              style: const TextStyle(
                fontFamily: 'NotoSansDevanagari',
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF4A5A50),
              ),
            ),
          ],

          // ---- What to do now ----
          if (advice.steps.isNotEmpty) ...[
            const SizedBox(height: 18),
            _SectionLabel(
              text: S.answerSteps(lang),
              icon: Icons.checklist_rounded,
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < advice.steps.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == advice.steps.length - 1 ? 0 : 11,
                ),
                child: _Step(number: i + 1, text: advice.steps[i]),
              ),
          ],

          // ---- The dose warning ----
          // Shown whenever the answer mentions spraying or any chemical. This is
          // the single most dangerous thing the app could get wrong, so the
          // warning is not optional and not hidden in small print.
          if (advice.mentionsChemical) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF6DFB0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Colors.orange.shade800,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      S.doseWarning(lang),
                      style: TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: 12.5,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ---- Expert route ----
          if (advice.shouldShowExpert) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.tintedPanel,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFCFE6D3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.answerExpertTitle(lang),
                          style: const TextStyle(
                            fontFamily: 'NotoSansDevanagari',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          S.answerExpertBody(lang),
                          style: const TextStyle(
                            fontFamily: 'NotoSansDevanagari',
                            fontSize: 12.5,
                            height: 1.45,
                            color: Color(0xFF56675C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 13),
          Text(
            S.aiDisclaimer(lang),
            style: const TextStyle(
              fontFamily: 'NotoSansDevanagari',
              fontSize: 10.5,
              color: Color(0xFFA3ADA6),
            ),
          ),
        ],
      ),
    );
  }
}

/// The white rounded container every answer sits in.
class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(color: const Color(0xFFE4EDE6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3D20).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final AdviceConfidence confidence;
  final String lang;

  const _ConfidenceBadge({required this.confidence, required this.lang});

  @override
  Widget build(BuildContext context) {
    final (label, colour, icon) = switch (confidence) {
      AdviceConfidence.high => (
        S.confidenceHigh(lang),
        AppColors.accent,
        Icons.verified_rounded,
      ),
      AdviceConfidence.medium => (
        S.confidenceMedium(lang),
        const Color(0xFF8A7A2E),
        Icons.lightbulb_outline_rounded,
      ),
      AdviceConfidence.low => (
        S.confidenceLow(lang),
        const Color(0xFFB4632A),
        Icons.help_outline_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colour),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'NotoSansDevanagari',
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: colour,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final IconData icon;

  const _SectionLabel({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.accent),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'NotoSansDevanagari',
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

/// One numbered action.
class _Step extends StatelessWidget {
  final int number;
  final String text;

  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.tintedPanel,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'NotoSansDevanagari',
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF33443A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
