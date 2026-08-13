import 'package:flutter/material.dart';

import '../../data/app_language.dart';
import '../../data/districts.dart';
import '../../theme/app_colors.dart';
import '_placeholder.dart';

/// The Guide — the farmer's offline library.
///
/// This is the tab that holds everything Shruti described: which crops grow in
/// their district, what to plant in which season, and the diseases with real
/// photographs and solutions.
///
/// Everything here is bundled inside the app, so it works with no internet from
/// the very first launch. The district only decides WHICH part is shown.
///
/// Currently a placeholder — it fills up once the crop data is verified.
class GuideTab extends StatelessWidget {
  final AppLanguage language;
  final District district;

  const GuideTab({super.key, required this.language, required this.district});

  @override
  Widget build(BuildContext context) {
    final region = findRegionForDistrict(district.id) ?? '';
    return TabPlaceholder(
      icon: Icons.menu_book_rounded,
      title: language.code == 'en' ? 'Guide' : 'माहिती',
      lines: [
        language.code == 'en'
            ? 'Crops grown here · what to plant when · diseases with photos'
            : 'येथील पिके · कधी काय लावावे · रोग व उपाय',
        '$region — ${language.code == 'en' ? district.en : district.mr}',
      ],
      accent: AppColors.accent,
    );
  }
}
