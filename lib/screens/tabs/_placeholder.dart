import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A tidy stand-in for a tab that isn't built yet.
///
/// Deliberately looks deliberate. An empty white screen reads as a bug; this
/// reads as "not finished yet", which is the truth.
class TabPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lines;
  final Color accent;

  const TabPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.lines,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tintedPanel,
                ),
                child: Icon(icon, size: 34, color: accent),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              for (final l in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    l,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'NotoSansDevanagari',
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF7B877E),
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
