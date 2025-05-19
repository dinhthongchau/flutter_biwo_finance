import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  static const String routeName = "/onboarding-screen";

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Text("hello OnboardingScreen")
    );
  }
}

