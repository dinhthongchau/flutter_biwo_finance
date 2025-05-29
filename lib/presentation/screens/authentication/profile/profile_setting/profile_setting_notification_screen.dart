import 'package:flutter/material.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:go_router/go_router.dart';

class ProfileSettingNotificationScreen extends StatefulWidget {
  static const String routeName = '/profile-setting-notification';
  const ProfileSettingNotificationScreen({super.key});

  @override
  State<ProfileSettingNotificationScreen> createState() =>
      _ProfileSettingNotificationScreenState();
}

class _ProfileSettingNotificationScreenState
    extends State<ProfileSettingNotificationScreen> {
  bool generalNotification = true;
  bool sound = true;
  bool soundCall = true;
  bool vibrate = true;
  bool transactionUpdate = false;
  bool expenseReminder = false;
  bool budgetNotifications = false;
  bool lowBalanceAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: Column(
        children: [
          // AppBar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 24,
                left: 8,
                right: 24,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/profile-setting-screen'),
                  ),
                  const Text(
                    'Notification Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.notifications_none,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          // Nội dung
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 40),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.honeydew,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ListView(
                  children: [
                    _buildSwitch(
                      'General Notification',
                      generalNotification,
                      (v) => setState(() => generalNotification = v),
                    ),
                    _buildSwitch(
                      'Sound',
                      sound,
                      (v) => setState(() => sound = v),
                    ),
                    _buildSwitch(
                      'Sound Call',
                      soundCall,
                      (v) => setState(() => soundCall = v),
                    ),
                    _buildSwitch(
                      'Vibrate',
                      vibrate,
                      (v) => setState(() => vibrate = v),
                    ),
                    _buildSwitch(
                      'Transaction Update',
                      transactionUpdate,
                      (v) => setState(() => transactionUpdate = v),
                    ),
                    _buildSwitch(
                      'Expense Reminder',
                      expenseReminder,
                      (v) => setState(() => expenseReminder = v),
                    ),
                    _buildSwitch(
                      'Budget Notifications',
                      budgetNotifications,
                      (v) => setState(() => budgetNotifications = v),
                    ),
                    _buildSwitch(
                      'Low Balance Alerts',
                      lowBalanceAlerts,
                      (v) => setState(() => lowBalanceAlerts = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: AppColors.blackHeader),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.caribbeanGreen,
          ),
        ],
      ),
    );
  }
}
