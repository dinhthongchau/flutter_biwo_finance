import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management/presentation/shared_data.dart';

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
              duration: const Duration(milliseconds: 5000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final double scale = value;
                final double iconOpacity = (value - 0.3).clamp(0.0, 1.0);
                return Transform.scale(
                  scale: scale,
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
                    child: Center(
                      child: Opacity(
                        opacity: iconOpacity,
                        child: const Icon(
                          Icons.check,
                          color: AppColors.caribbeanGreen,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: const Text(
                'Password Has Been\nChanged Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
