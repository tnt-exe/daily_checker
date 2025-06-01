import 'package:daily_checker/daily_jobs_screen.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  final String _correctPassword = "dummy";
  String? _errorMessage;

  void _login() {
    if (_passwordController.text == _correctPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DailyJobsScreen()),
      );
    } else {
      setState(() {
        _errorMessage = "Incorrect";
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: screenWidth < 1200 ? screenWidth : screenWidth / 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Passcode',
                    border: const OutlineInputBorder(),
                    errorText: _errorMessage,
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Access'),
                ),
                const Spacer(flex: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
