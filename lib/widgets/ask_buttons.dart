import 'package:flutter/material.dart';

import '../data/strings.dart';
import '../theme/app_colors.dart';

/// The three ways a farmer can ask a question.
///
/// Voice is a full-width button on its own row; photo and text are two tiles
/// underneath. Voice reads as the main action because of its position and
/// width — not because it is enormous. Shruti's instruction was "not too big,
/// just proper so it looks good".
///
/// Why voice leads at all: a farmer who cannot read or type can still speak.
/// Most apps bury the microphone in a corner of a text box, which is exactly
/// backwards for this audience.
class AskButtons extends StatelessWidget {
  final String lang;
  final bool enabled; // false when there is no internet — these need Gemini
  final VoidCallback onVoice;
  final VoidCallback onPhoto;
  final VoidCallback onText;

  const AskButtons({
    super.key,
    required this.lang,
    required this.enabled,
    required this.onVoice,
    required this.onPhoto,
    required this.onText,
  });

  @override
  Widget build(BuildContext context) {
    // Dimmed rather than hidden. A farmer who has used the app before should
    // still see where his buttons are — they just aren't working right now.
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          children: [
            _VoiceButton(lang: lang, onTap: onVoice),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SmallTile(
                    icon: Icons.photo_camera_rounded,
                    label: S.askByPhoto(lang),
                    onTap: onPhoto,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SmallTile(
                    icon: Icons.edit_rounded,
                    label: S.askByText(lang),
                    onTap: onText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceButton extends StatelessWidget {
  final String lang;
  final VoidCallback onTap;

  const _VoiceButton({required this.lang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.primary, Color(0xFF2C7A3F)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular mic badge — recognisable at a glance, without the
              // button having to take over the whole screen.
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                child: const Icon(Icons.mic_rounded, color: Colors.white, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.askByVoice(lang),
                      style: const TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      S.askByVoiceHint(lang),
                      style: TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SmallTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E9E2), width: 1.3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tintedPanel,
                ),
                child: Icon(icon, color: AppColors.accent, size: 21),
              ),
              const SizedBox(height: 8),
              // The labels are longer than the old one-word ones, and Marathi
              // and Hindi are longer again. FittedBox shrinks the text a little
              // rather than wrapping or clipping it, so the tile still looks
              // right on a narrow phone in all three languages.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'NotoSansDevanagari',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
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
}
