import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iqalqalah/screens/onboarding/welcome_screen.dart';
import 'package:iqalqalah/theme/app_theme.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const IQalqalah());
}

class IQalqalah extends StatelessWidget {
  const IQalqalah({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iQalqalah',
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
