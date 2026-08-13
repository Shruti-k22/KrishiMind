import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:krishimind/screens/splash_screen.dart';

// The default Flutter project ships a test for the blue counter app, which we
// deleted. This replaces it with a simple check that the splash screen builds
// and shows the first tagline in English.
void main() {
  testWidgets('Splash screen shows the English tagline first', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(); // let the first frame settle

    expect(find.text('Your Smart Farming Advisor'), findsOneWidget);
  });
}
