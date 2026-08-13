import 'package:flutter/material.dart';

import '../../data/app_language.dart';
import '../../theme/app_colors.dart';
import '_placeholder.dart';

/// Past questions, stored on this phone.
///
/// Works without a login. Logging in only matters if the farmer changes phone
/// or reinstalls — then the history can come back.
class HistoryTab extends StatelessWidget {
  final AppLanguage language;

  const HistoryTab({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return TabPlaceholder(
      icon: Icons.history_rounded,
      title: language.code == 'en' ? 'Your questions' : 'तुमचे प्रश्न',
      lines: [
        language.code == 'en'
            ? 'Everything you ask will be saved here on this phone'
            : 'तुम्ही विचारलेले सर्व प्रश्न इथे या फोनमध्ये जतन होतील',
      ],
      accent: AppColors.accent,
    );
  }
}
