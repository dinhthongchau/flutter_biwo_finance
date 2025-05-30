import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_main/profile_screen.dart';
import 'package:finance_management/presentation/screens/authentication/login/login_screen.dart';

class ProfileSplashScreen extends StatefulWidget {
  static const String routeName = '/profile-splash';
  final String message;
  const ProfileSplashScreen({super.key, this.message = 'Action Successful!'});

  @override
  State<ProfileSplashScreen> createState() => _ProfileSplashScreenState();
}

class _ProfileSplashScreenState extends State<ProfileSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final message =
          GoRouterState.of(context).extra as String? ?? widget.message;
      if (message == 'Account deleted successfully!') {
        context.go(LoginScreen.routeName);
      } else {
        context.go(ProfileScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final message =
        GoRouterState.of(context).extra as String? ?? widget.message;
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 6),
                    ),
                    child: Center(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 36),
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
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
