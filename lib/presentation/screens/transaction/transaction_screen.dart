import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';

class TransactionScreen extends StatelessWidget with TransactionScreenMixin {
  static const String routeName = "/transaction-screen";

  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildHeader(
        context,
        "Transaction",
        "${HomeScreen.routeName}${NotificationScreen.routeName}",
      ),
      backgroundColor: AppColors.caribbeanGreen,
      body: Container(
        padding: SharedLayout.getScreenPadding(context),
        child: buildBlocBody(),
      ),
    );
  }
}
