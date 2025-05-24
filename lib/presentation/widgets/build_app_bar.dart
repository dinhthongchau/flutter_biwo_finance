// lib/presentation/widgets/notification_bell_icon.dart
import 'package:finance_management/presentation/bloc/notification/notification_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Assuming NotificationBloc is here
import 'package:finance_management/presentation/shared_data.dart'; // Assuming AppColors is here
import 'package:finance_management/presentation/bloc/notification/notification_bloc.dart'; // Adjust path if needed
import 'package:finance_management/presentation/bloc/notification/notification_state.dart';
import 'package:go_router/go_router.dart'; // Adjust path if needed

Widget notificationBellIcon({
  required String iconPath,
  VoidCallback? onPressed,
  Color iconBackgroundColor = AppColors.honeydew,
  Color badgeColor = AppColors.redColor,
  Color badgeTextColor = AppColors.honeydew,
}) {
  return BlocBuilder<NotificationBloc, NotificationState>(
    builder: (context, state) {
      final notificationCount = state.notificationCount ?? -1;
      return Stack(
        children: [
          IconButton(
            onPressed: onPressed, // đặt onPressed ở đây
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(iconPath, height: 19, width: 15),
            ),
          ),
          if (notificationCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  state.notificationCount.toString(),
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

PreferredSizeWidget buildAppBarNotification(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: AppBar(
      backgroundColor: AppColors.caribbeanGreen,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.honeydew),
        onPressed: () => context.pop(),
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
        // In NotificationScreen._buildAppBar (or where the Row is defined)
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                final confirm = await DialogUtils.showDeleteConfirmationDialog(
                  context,
                  content: 'Bạn có chắc chắn muốn xóa hết thông báo không?',
                );
                if (confirm == true) {
                  if (context.mounted) {
                    context.read<NotificationBloc>().add(
                      const ClearNotifications(),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    final count = state.notificationCount ?? 0;
                    return Text(
                      'Remove all ($count)',
                      style: const TextStyle(
                        color: AppColors.redColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 30),
      ],
    ),
  );
}

PreferredSizeWidget buildHeader(
  BuildContext context,
  String title,
  String notificationsScreenPath,
) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight + 25),
    child: Container(
      padding: const EdgeInsets.only(left: 38, right: 36, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.fenceGreen,
            ),
          ),
          const Spacer(),
          notificationBellIcon(
            iconPath: Assets.functionalIcon.vector.path,
            onPressed: () {
              try {
                context.push(notificationsScreenPath);
              } catch (e) {
                debugPrint('Error navigating to notifications: $e');
              }
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildWelcomeText() {
  return const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Hi, Welcome Back',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.fenceGreen,
        ),
      ),
      Text(
        'Good Morning',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.fenceGreen,
        ),
      ),
    ],
  );
}

Widget _buildNotificationButton(
  BuildContext context,
  String notificationsScreenPath,
) {
  return notificationBellIcon(
    iconPath: Assets.functionalIcon.vector.path,
    onPressed: () {
      context.push(notificationsScreenPath);
    },
  );
}

PreferredSizeWidget buildHeaderHome(
  BuildContext context,
  String notificationsScreenPath,
) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight + 25),
    child: Padding(
      padding: const EdgeInsets.only(left: 37, right: 36, top: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildWelcomeText(),
          _buildNotificationButton(context, notificationsScreenPath),
        ],
      ),
    ),
  );
}
