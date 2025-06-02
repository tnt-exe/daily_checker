import 'package:daily_checker/data/auth_service.dart';
import 'package:daily_checker/view/daily_jobs_screen.dart';
import 'package:daily_checker/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  void _login() async {
    try {
      final isValid = await _authService.isCorrectPasscode(
        _passwordController.text,
      );
      if (isValid) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DailyJobsScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Incorrect';
        });
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _errorMessage = 'Error occurred.';
        });
      }
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
      appBar: const CustomAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: screenWidth < 1200 ? screenWidth : screenWidth * 0.4,
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
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text(
                    'Access',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
