import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


mixin NotificationScreenMixin {

  Widget buildBody(List<Map<String, dynamic>> notificationData, NotificationState state, BuildContext context) {

      if ( state is NotificationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'An error occurred'),
            backgroundColor: AppColors.redColor,
          ),
        );
      }
      if (state is NotificationLoading) {
        return  Center(child:  LoadingUtils.buildSpinKitSpinningLinesWhite());
      }
        return    Container(
          height: double.infinity,
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
                  if (state is NotificationLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (state is NotificationError)
                    Center(
                      child: Text(
                        state.errorMessage ?? 'An error occurred',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.oceanBlue,
                        ),
                      ),
                    ),
                  if (notificationData.isEmpty && state is! NotificationLoading)
                    const Center(
                      child: Text(
                        'No notifications available',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.oceanBlue,
                        ),
                      ),
                    ),
                  if (notificationData.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notificationData.length,
                      itemBuilder: (context, index) {
                        final sectionData = notificationData[index];
                        final String sectionTitle = sectionData['section'];
                        final List<Map<String, dynamic>> items = sectionData['items'];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(sectionTitle),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, itemIndex) {
                                return _buildNotificationItem(items[itemIndex]);
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
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

  Widget _buildNotificationItem(Map<String, dynamic> data) {
    final String iconPath = data['iconPath'];
    final String title = data['title'];
    final String subtitle = data['subtitle'];
    final String time = data['time'];

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
                color: AppColors.caribbeanGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                iconPath,
                height: 24,
                width: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.fenceGreen,
                  BlendMode.srcIn,
                ),
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

  List<Map<String, dynamic>> groupNotificationsBySection(
      List<NotificationModel> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final Map<String, List<Map<String, dynamic>>> grouped = {
      'Today': [],
      'Yesterday': [],
      'This Week': [],
    };

    for (var notification in notifications) {
      final date = DateTime.parse(notification.date);
      final notificationMap = notification.toMap();
      if (date.day == today.day &&
          date.month == today.month &&
          date.year == today.year) {
        grouped['Today']!.add(notificationMap);
      } else if (date.day == yesterday.day &&
          date.month == yesterday.month &&
          date.year == yesterday.year) {
        grouped['Yesterday']!.add(notificationMap);
      } else if (date.isAfter(weekStart)) {
        grouped['This Week']!.add(notificationMap);
      }
    }

    return [
      if (grouped['Today']!.isNotEmpty)
        {'section': 'Today', 'items': grouped['Today']!},
      if (grouped['Yesterday']!.isNotEmpty)
        {'section': 'Yesterday', 'items': grouped['Yesterday']!},
      if (grouped['This Week']!.isNotEmpty)
        {'section': 'This Week', 'items': grouped['This Week']!},
    ];
  }
}