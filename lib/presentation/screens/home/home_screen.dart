
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget with HomeScreenMixin {
  static const String routeName = '/home-screen';
  final String notificationsScreenPath;
  final String chatbotFinanceScreenPath;

  const HomeScreen({
    super.key,
    required this.notificationsScreenPath, required this.chatbotFinanceScreenPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildHeaderHome(context, notificationsScreenPath),
      floatingActionButton:  buildFloatingActionButtonChatbotFinance(context, chatbotFinanceScreenPath),
      backgroundColor: AppColors.caribbeanGreen,
      body: Container(
        padding: SharedLayout.getScreenPadding(context), // Mobile padding
        child: buildBody(context),
      ),
    );
  }


}


