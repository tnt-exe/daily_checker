import 'package:daily_checker/view/daily_jobs_screen.dart';
import 'package:daily_checker/firebase_options.dart';
import 'package:daily_checker/view/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DailyChecker());
}

class DailyChecker extends StatelessWidget {
  const DailyChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Jobs',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurpleAccent,
      ),
      home: kIsWeb ? const LoginPage() : const DailyJobsScreen(),
    );
  }
}
