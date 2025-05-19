import 'package:flutter/material.dart';

class TransactionScreen extends StatelessWidget {
  static const String routeName = "/transaction-screen";

  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Text("hello Transaction")
    );
  }
}

