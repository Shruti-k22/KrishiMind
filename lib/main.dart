import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  // Flutter has to be ready before we touch anything native.
  WidgetsFlutterBinding.ensureInitialized();

  // Connects the app to the Firebase project, using google-services.json.
  // Wrapped in a try so a Firebase problem can never stop the app opening —
  // the farmer's dashboard, guide and weather do not need an account, and it
  // would be absurd for a login service to break an app that works without one.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase failed to start: $e');
  }

  runApp(const KrishiMindApp());
}

/// The root of the app. Its only jobs are: set the theme, and decide which
/// screen opens first. Keep it this small — screens belong in their own files.
class KrishiMindApp extends StatelessWidget {
  const KrishiMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrishiMind',

      // Hides the "DEBUG" ribbon in the corner while testing.
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
