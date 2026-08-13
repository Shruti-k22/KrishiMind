import 'package:flutter/material.dart';

import '../data/app_language.dart';
import '../data/districts.dart';
import '../data/strings.dart';
import '../theme/app_colors.dart';
import 'tabs/guide_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';

/// The main app frame: four tabs along the bottom, one of them showing at a time.
///
/// Why a "shell": the bottom bar must never disappear or move while switching
/// tabs. So one widget owns the bar, and only the body above it changes.
///
/// Experts is deliberately NOT a tab. Nobody opens an experts tab out of
/// curiosity — but they will tap it the moment the app says it isn't sure. So
/// it appears underneath an answer instead, where it is actually wanted.
class HomeShell extends StatefulWidget {
  final AppLanguage language;
  final District district;

  const HomeShell({super.key, required this.language, required this.district});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final lang = widget.language.code;

    final tabs = [
      HomeTab(language: widget.language, district: widget.district),
      GuideTab(language: widget.language, district: widget.district),
      HistoryTab(language: widget.language),
      ProfileTab(language: widget.language, district: widget.district),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,

      // IndexedStack keeps all four tabs alive instead of rebuilding them each
      // time. So the weather doesn't reload every time the farmer taps Home,
      // and a half-scrolled guide stays where it was.
      body: IndexedStack(index: _index, children: tabs),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            height: 66,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppColors.tintedPanel,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(
                  Icons.home_rounded,
                  color: AppColors.primary,
                ),
                label: S.navHome(lang),
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                ),
                label: S.navGuide(lang),
              ),
              NavigationDestination(
                icon: const Icon(Icons.history_outlined),
                selectedIcon: const Icon(
                  Icons.history_rounded,
                  color: AppColors.primary,
                ),
                label: S.navHistory(lang),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                ),
                label: S.navProfile(lang),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
