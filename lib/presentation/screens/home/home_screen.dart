import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget with HomeScreenMixin {
  static const String routeName = '/home-screen';
  final String label;
  final String notificationsScreenPath;

  const HomeScreen({
    super.key,
    required this.label,
    required this.notificationsScreenPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildHeaderHome(context, notificationsScreenPath),
      backgroundColor: AppColors.caribbeanGreen,
      body: buildBody(context),
    );
  }
}
