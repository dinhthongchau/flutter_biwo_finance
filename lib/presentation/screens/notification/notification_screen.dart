import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  static const String routeName = 'notifications';
  final String label;

  const NotificationScreen({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: AppColors.caribbeanGreen,
        elevation: 0,
        // leading: const IconButton(
        //   Icons.arrow_back,
        //   color: AppColors.honeydew,
        // ),
        //leading is iconbutton able to pop
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.honeydew,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Center(
          child: Text(
            'Notification',
            style: TextStyle(
              color: AppColors.fenceGreen,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.honeydew,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/FunctionalIcon/Vector.svg',
              height: 19,
              width: 15,
            ),
          ),
          const SizedBox(width: 30,)
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.honeydew,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Today'),
              _buildNotificationItem(
                iconPath: 'assets/FunctionalIcon/Vector.svg', // Placeholder
                title: 'Reminder!',
                subtitle: 'Set up your automatic savings to meet your savings goal...',
                time: '17:00 - April 24',
                iconColor: AppColors.caribbeanGreen,
              ),
              _buildNotificationItem(
                iconPath: 'assets/FunctionalIcon/Vector-28.svg', // Placeholder
                title: 'New Update',
                subtitle: 'Set up your automatic savings to meet your savings goal...',
                time: '17:00 - April 24',
                iconColor: AppColors.caribbeanGreen,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Yesterday'),
              _buildNotificationItem(
                iconPath: 'assets/FunctionalIcon/Vector-25.svg', // Placeholder
                title: 'Transactions',
                subtitle: 'A new transaction has been registered\nGroceries | Pantry | -\$100.00',
                time: '17:00 - April 24',
                iconColor: AppColors.caribbeanGreen,
              ),
              _buildNotificationItem(
                iconPath: 'assets/FunctionalIcon/Vector.svg', // Placeholder
                title: 'Reminder!',
                subtitle: 'Set up your automatic savings to meet your savings goal...',
                time: '17:00 - April 24',
                iconColor: AppColors.caribbeanGreen,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('This Week'),
              _buildNotificationItem(
                iconPath: 'assets/FunctionalIcon/Vector-26.svg', // Placeholder
                title: 'Expense Record',
                subtitle: 'We recommend that you be more attentive to your finances',
                time: '17:00 - April 24',
                iconColor: AppColors.caribbeanGreen,
              ),
              _buildNotificationItem(
                iconPath: 'assets/FunctionalIcon/Vector-25.svg', // Placeholder
                title: 'Transactions',
                subtitle: 'A new transaction has been registered\nFood | Dinner | -\$70.40',
                time: '17:00 - April 24',
                iconColor: AppColors.caribbeanGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.fenceGreen,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String iconPath,
    required String title,
    required String subtitle,
    required String time,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox( // Thêm SizedBox để cố định kích thước
            width: 40,
            height: 40,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                iconPath,
                height: 24,
                width: 24,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fenceGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.oceanBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.oceanBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}