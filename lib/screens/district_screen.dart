import 'package:flutter/material.dart';

import '../data/app_language.dart';
import '../data/app_prefs.dart';
import '../data/districts.dart';
import '../data/strings.dart';
import '../theme/app_colors.dart';
import 'home_shell.dart';

/// District selection.
///
/// No GPS, deliberately. Shruti's reasoning: living in Kolhapur doesn't mean
/// you read Marathi, so language and district are two separate questions — and
/// asking for location permission is one more scary popup that can go wrong.
/// The farmer simply picks their district from a list.
///
/// Everything on this screen is written in the language chosen on the previous
/// screen. By this point we know it, so there is no reason to show three.
class DistrictScreen extends StatefulWidget {
  final AppLanguage language;

  const DistrictScreen({super.key, required this.language});

  @override
  State<DistrictScreen> createState() => _DistrictScreenState();
}

class _DistrictScreenState extends State<DistrictScreen> {
  String? _selectedId;
  bool _saving = false;

  String get _lang => widget.language.code;

  /// Devanagari for Marathi and Hindi, Latin script for English.
  String _name(District d) => _lang == 'en' ? d.en : d.mr;
  String _groupName(DistrictGroup g) => _lang == 'en' ? g.en : g.mr;

  Future<void> _continue() async {
    if (_selectedId == null || _saving) return;
    setState(() => _saving = true);

    // Save BOTH choices to the phone. From now on the app opens straight to
    // the dashboard and never asks these questions again.
    await AppPrefs.saveLanguage(_lang);
    await AppPrefs.saveDistrict(_selectedId!);

    if (!mounted) return;
    // pushAndRemoveUntil throws away every screen behind this one. Once setup
    // is finished, pressing back must not walk the farmer back into it.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomeShell(
          language: widget.language,
          district: findDistrictById(_selectedId)!,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedId != null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9F5EA), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ---- Back to the language screen ----
              // A visible button, not just the Android back gesture. Many
              // farmers won't know the gesture, and a wrong language choice
              // would otherwise trap them on this screen.
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE2E9E3),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 21,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ---- Header ----
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 14),
                child: Column(
                  children: [
                    Text(
                      S.districtTitle(_lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      S.districtSubtitle(_lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF6F7C72),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- The scrolling list, grouped by division ----
              // Expanded means "take all the space left over after the header
              // and the button". Without it the list would try to be infinitely
              // tall and Flutter would throw an error.
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 10),
                  children: [
                    for (final group in maharashtraDistricts) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                        child: Text(
                          _groupName(group),
                          style: const TextStyle(
                            fontFamily: 'NotoSansDevanagari',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      for (final d in group.districts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: _DistrictTile(
                            name: _name(d),
                            isSelected: _selectedId == d.id,
                            onTap: () => setState(() => _selectedId = d.id),
                          ),
                        ),
                    ],
                    const SizedBox(height: 6),
                  ],
                ),
              ),

              // ---- Continue ----
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
                child: SizedBox(
                  height: 56,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      // Greyed out until a district is picked. Here that is
                      // safe: unlike the language screen, there is no sensible
                      // district to guess on the farmer's behalf.
                      disabledBackgroundColor: const Color(0xFFD6DED8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    onPressed: hasSelection ? _continue : null,
                    child: Text(
                      S.continueLabel(_lang),
                      style: TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: hasSelection
                            ? Colors.white
                            : const Color(0xFF97A29A),
                      ),
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

/// One district row. Shorter than the language cards because there are 36 of
/// them — but still 58px, comfortably above the 48px minimum touch target
/// Android recommends.
class _DistrictTile extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _DistrictTile({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isSelected ? AppColors.accent : const Color(0xFFE2E9E3),
              width: isSelected ? 2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.14)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: isSelected ? 10 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'NotoSansDevanagari',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 21,
                height: 21,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accent
                        : const Color(0xFFC6D0C8),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                      ),
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
