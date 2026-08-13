import 'package:flutter/material.dart';

import '../../data/advice.dart';
import '../../data/app_language.dart';
import '../../data/districts.dart';
import '../../data/gemini_service.dart';
import '../../data/strings.dart';
import '../../secrets.dart';
import '../../theme/app_colors.dart';
import '../../widgets/answer_card.dart';

/// The text conversation.
///
/// A chat rather than a single box-and-answer, decided deliberately: almost every
/// farmer in Maharashtra already uses WhatsApp, so a chat needs no explaining.
/// It also means a follow-up like "which one is cheapest?" is natural, and the
/// same screen will hold the voice and image answers later — we build the answer
/// layout once and reuse it three times.
class TextAskScreen extends StatefulWidget {
  final AppLanguage language;
  final District district;

  const TextAskScreen({
    super.key,
    required this.language,
    required this.district,
  });

  @override
  State<TextAskScreen> createState() => _TextAskScreenState();
}

class _TextAskScreenState extends State<TextAskScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _turns = <ChatTurn>[];

  bool _busy = false;

  /// Kept so the retry button can resend the same question without the farmer
  /// having to type it again.
  String _lastQuestion = '';

  String get _lang => widget.language.code;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String raw) async {
    final question = raw.trim();
    if (question.isEmpty || _busy) return;

    _controller.clear();
    _lastQuestion = question;

    setState(() {
      _turns.add(ChatTurn.farmer(question));
      _busy = true;
    });
    _scrollToEnd();

    // The history passed in excludes the question we just added — the service
    // appends it as the newest turn itself.
    final history = _turns.sublist(0, _turns.length - 1);

    final outcome = await GeminiService.ask(
      question: question,
      langCode: _lang,
      district: widget.district,
      history: history,
    );

    if (!mounted) return;

    setState(() {
      _busy = false;
      if (outcome.isOk) {
        _turns.add(ChatTurn.answer(outcome.advice));
      } else {
        // The technical detail is appended only while we are still getting this
        // working. Remove the `+ detail` part before submission — a farmer must
        // never see an HTTP code.
        final detail = outcome.detail == null ? '' : '  [${outcome.detail}]';
        _turns.add(ChatTurn.failed('${_messageFor(outcome.error!)}$detail'));
      }
    });
    _scrollToEnd();
  }

  String _messageFor(GeminiError e) => switch (e) {
    GeminiError.quotaExhausted => S.askQuotaOver(_lang),
    // These two are problems in the project, not the farmer's fault, so they are
    // written in English — the only person who can fix them is the developer.
    GeminiError.noKey => 'No Gemini API key. Paste your key in lib/secrets.dart.',
    GeminiError.badKey =>
      'The Gemini key was rejected. Check it in lib/secrets.dart.',
    GeminiError.failed => S.askFailed(_lang),
  };

  void _scrollToEnd() {
    // One frame later, so the new bubble has been measured and we know the real
    // height to scroll to.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      body: SafeArea(
        child: Column(
          children: [
            _Header(language: widget.language, district: widget.district),
            Expanded(
              child: _turns.isEmpty
                  ? _EmptyState(lang: _lang, onPick: _send)
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      itemCount: _turns.length + (_busy ? 1 : 0),
                      itemBuilder: (context, i) {
                        // The thinking indicator lives at the end of the list, so
                        // it appears exactly where the answer will.
                        if (i == _turns.length) {
                          return _Thinking(lang: _lang);
                        }
                        final turn = _turns[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: turn.fromFarmer
                              ? _QuestionBubble(text: turn.question)
                              : turn.advice != null
                                    ? AnswerCard(
                                        advice: turn.advice!,
                                        lang: _lang,
                                      )
                                    : _FailedBubble(
                                        message: turn.error ?? '',
                                        retryLabel: S.retry(_lang),
                                        onRetry: () => _send(_lastQuestion),
                                      ),
                        );
                      },
                    ),
            ),
            _InputBar(
              controller: _controller,
              hint: S.askHint(_lang),
              enabled: !_busy,
              onSend: () => _send(_controller.text),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top bar. Not an AppBar, because we want the district on a second line and
/// full control of the spacing.
class _Header extends StatelessWidget {
  final AppLanguage language;
  final District district;

  const _Header({required this.language, required this.district});

  @override
  Widget build(BuildContext context) {
    final name = language.code == 'en' ? district.en : district.mr;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3D20).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.askTitle(language.code),
                  style: const TextStyle(
                    fontFamily: 'NotoSansDevanagari',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7B877E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Image.asset('assets/branding/emblem.png', height: 34),
        ],
      ),
    );
  }
}

/// What the farmer sees before asking anything.
///
/// An empty chat is intimidating: a blank box gives no clue how much to write.
/// The three example questions are one tap each and quietly teach the right
/// level of detail.
class _EmptyState extends StatelessWidget {
  final String lang;
  final ValueChanged<String> onPick;

  const _EmptyState({required this.lang, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 20),
      children: [
        Center(
          child: Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tintedPanel,
            ),
            child: const Icon(
              Icons.forum_rounded,
              size: 36,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          S.askOpening(lang),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'NotoSansDevanagari',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          S.askOpeningHelp(lang),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'NotoSansDevanagari',
            fontSize: 13,
            height: 1.5,
            color: Color(0xFF7B877E),
          ),
        ),
        const SizedBox(height: 26),
        Text(
          S.askExamplesTitle(lang),
          style: const TextStyle(
            fontFamily: 'NotoSansDevanagari',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: Color(0xFF9BA69E),
          ),
        ),
        const SizedBox(height: 10),
        for (final q in S.askExamples(lang))
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onPick(q),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2EBE4)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          q,
                          style: const TextStyle(
                            fontFamily: 'NotoSansDevanagari',
                            fontSize: 13.5,
                            height: 1.45,
                            color: Color(0xFF44544A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.north_east_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        if (!Secrets.hasGeminiKey) ...[
          const SizedBox(height: 18),
          // Developer-facing, in English, and it disappears the moment the key is
          // in place. Better than the farmer tapping send and getting silence.
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF3DDB4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.key_rounded,
                  size: 18,
                  color: Colors.orange.shade800,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Setup step: paste your free Gemini API key into '
                    'lib/secrets.dart, then hot restart.',
                    style: TextStyle(
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
      ],
    );
  }
}

/// The farmer's own question.
class _QuestionBubble extends StatelessWidget {
  final String text;
  const _QuestionBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, Color(0xFF2C7A3F)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'NotoSansDevanagari',
              fontSize: 14.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Three dots that fade in turn while the model thinks.
///
/// Worth the few lines: without any movement on screen, several seconds of
/// silence reads as "the app has frozen".
class _Thinking extends StatefulWidget {
  final String lang;
  const _Thinking({required this.lang});

  @override
  State<_Thinking> createState() => _ThinkingState();
}

class _ThinkingState extends State<_Thinking>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4EDE6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  // Each dot is a third of a cycle behind the one before it.
                  final t = (_c.value - i * 0.22) % 1.0;
                  final lift = t < 0.5 ? t * 2 : (1 - t) * 2;
                  return Padding(
                    padding: EdgeInsets.only(right: i == 2 ? 0 : 5),
                    child: Opacity(
                      opacity: 0.35 + lift * 0.65,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(width: 10),
            Text(
              S.thinking(widget.lang),
              style: const TextStyle(
                fontFamily: 'NotoSansDevanagari',
                fontSize: 12.5,
                color: Color(0xFF7B877E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A failed request, with a retry that resends the same question.
class _FailedBubble extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _FailedBubble({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF1F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3D6D3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 18,
                color: Colors.red.shade400,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'NotoSansDevanagari',
                    fontSize: 13.5,
                    height: 1.45,
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              label: Text(
                retryLabel,
                style: const TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The bottom bar: field plus a round send button.
class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.hint,
    required this.enabled,
    required this.onSend,
  });

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_check);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_check);
    super.dispose();
  }

  void _check() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _hasText && widget.enabled;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6EDE7))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7F4),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2EBE4)),
              ),
              child: TextField(
                controller: widget.controller,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 14.5,
                  height: 1.4,
                  color: Color(0xFF2A382F),
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    fontFamily: 'NotoSansDevanagari',
                    fontSize: 14,
                    color: Color(0xFF9BA69E),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Grows slightly the moment there is something to send — a small,
          // cheap piece of feedback that makes the screen feel alive.
          AnimatedScale(
            scale: canSend ? 1.0 : 0.92,
            duration: const Duration(milliseconds: 180),
            child: Material(
              color: canSend ? AppColors.primary : const Color(0xFFCBD8CF),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: canSend ? widget.onSend : null,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
