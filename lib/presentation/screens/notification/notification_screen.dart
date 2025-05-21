import 'package:finance_management/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

class NotificationScreen extends StatelessWidget {
  static const String routeName = '/notifications';

  final String notificationDataJson = '''
[
  {
    "section": "Today",
    "items": [
      {
        "iconPath": "assets/FunctionalIcon/Vector.svg",
        "title": "Reminder!",
        "subtitle": "Set up your automatic savings to meet your savings goal...",
        "time": "17:00 - April 24",
        "iconColor": "AppColors.caribbeanGreen"
      },
      {
        "iconPath": "assets/FunctionalIcon/Vector-28.svg",
        "title": "New Update",
        "subtitle": "Set up your automatic savings to meet your savings goal...",
        "time": "17:00 - April 24",
        "iconColor": "AppColors.caribbeanGreen"
      }
    ]
  },
  {
    "section": "Yesterday",
    "items": [
      {
        "iconPath": "assets/FunctionalIcon/Vector-25.svg",
        "title": "Transactions",
        "subtitle": "A new transaction has been registered\\nGroceries | Pantry | -\$100.00",
        "time": "17:00 - April 24",
        "iconColor": "AppColors.caribbeanGreen"
      },
      {
        "iconPath": "assets/FunctionalIcon/Vector.svg",
        "title": "Reminder!",
        "subtitle": "Set up your automatic savings to meet your savings goal...",
        "time": "17:00 - April 24",
        "iconColor": "AppColors.caribbeanGreen"
      }
    ]
  },
  {
    "section": "This Week",
    "items": [
      {
        "iconPath": "assets/FunctionalIcon/Vector-26.svg",
        "title": "Expense Record",
        "subtitle": "We recommend that you be more attentive to your finances",
        "time": "17:00 - April 24",
        "iconColor": "AppColors.caribbeanGreen"
      },
      {
        "iconPath": "assets/FunctionalIcon/Vector-25.svg",
        "title": "Transactions",
        "subtitle": "A new transaction has been registered\\nFood | Dinner | -\$70.40",
        "time": "17:00 - April 24",
        "iconColor": "AppColors.caribbeanGreen"
      }
    ]
  }
]
''';

  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> notificationData = jsonDecode(notificationDataJson);

    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      appBar: _buildAppBar(context),
      body: _buildBody(notificationData),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: AppColors.caribbeanGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.honeydew,
          ),
          onPressed: () {
            context.pop();
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
          SizedBox(
            width: 40,
            height: 40,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.honeydew,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
              //  'assets/FunctionalIcon/Vector.svg',
                Assets.functionalIcon.vector.path,
                height: 19,
                width: 15,
              ),
            ),
          ),
          const SizedBox(width: 30),
        ],
      ),
    );
  }

  Widget _buildBody(List<dynamic> notificationData) {
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
            children: notificationData.map((sectionData) {
              final String sectionTitle = sectionData['section'];
              final List<dynamic> items = sectionData['items'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(sectionTitle),
                  ...items.map((item) => _buildNotificationItem(item)).toList(),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
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

  Widget _buildNotificationItem(Map<String, dynamic> data) {
    final String iconPath = data['iconPath'];
    final String title = data['title'];
    final String subtitle = data['subtitle'];
    final String time = data['time'];
    final Color iconColor = _getColorFromString(data['iconColor']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
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

  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'AppColors.caribbeanGreen':
        return AppColors.caribbeanGreen;
      case 'AppColors.fenceGreen':
        return AppColors.fenceGreen;
      case 'AppColors.honeydew':
        return AppColors.honeydew;
      case 'AppColors.oceanBlue':
        return AppColors.oceanBlue;
      case 'AppColors.lightBlue':
        return AppColors.lightBlue;
      case 'AppColors.vividBlue':
        return AppColors.vividBlue;
      case 'AppColors.lightGreen':
        return AppColors.lightGreen;
      case 'AppColors.blackHeader':
        return AppColors.blackHeader;
      default:
        return Colors.grey; // Default color if string is not recognized
    }
  }
}