import 'package:finance_management/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = "/login-screen";

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          onPressed: () {
            context.go(HomeScreen.routeName);
          },
          icon: const Icon(Icons.navigate_next_rounded),
        ),
      ),
    );
  }
}
