import 'package:daily_checker/daily_jobs_screen.dart';
import 'package:daily_checker/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DailyChecker());
}

class DailyChecker extends StatelessWidget {
  const DailyChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Jobs',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: kIsWeb ? const LoginPage() : const DailyJobsScreen(),
    );
  }
}
