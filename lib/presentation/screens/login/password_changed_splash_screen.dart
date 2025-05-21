import 'package:finance_management/presentation/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';

class PasswordChangedSplashScreen extends StatefulWidget {
  const PasswordChangedSplashScreen({super.key});

  @override
  State<PasswordChangedSplashScreen> createState() =>
      _PasswordChangedSplashScreenState();
}

class _PasswordChangedSplashScreenState
    extends State<PasswordChangedSplashScreen> {
  bool showButton = false;

  @override
  void initState() {
    super.initState();
    // Show button after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => showButton = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: (0.08 * 255).round().toDouble(),
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                      ),
                      child: const Center(
                        child: Icon(Icons.check, color: Colors.white, size: 64),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Password Has Been\nChanged Successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            if (showButton)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.caribbeanGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  context.go(LoginScreen.routeName);
                },
                child: const Text(
                  'Back to Log In',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
