import 'package:finance_management/presentation/screens/chatbot_finance/chatbot_finance_screen_mixin.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';

class ChatbotFinanceScreen extends StatelessWidget with ChatbotFinanceScreenMixin {
  static const String routeName = '/chatbot-finance-screen';

   ChatbotFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use default AppBar with custom title and actions
      appBar: AppBar(
        title: const Text('ChatBot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showInfoDialog(context), // Call mixin method
          ),
        ],
      ),
      backgroundColor: AppColors.caribbeanGreen,
      body: Container(
        padding: SharedLayout.getScreenPadding(context),
        child: buildBody(context),
      ),
    );
  }
}