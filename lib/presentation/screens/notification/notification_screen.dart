import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationScreen extends StatefulWidget {
  static const String routeName = '/notifications-screen';

  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> with NotificationScreenMixin {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final notificationData = groupNotificationsBySection(
          state.notifications ?? [],
        );

        return Scaffold(
          backgroundColor: AppColors.caribbeanGreen,
          appBar: buildAppBarNotification(context),
          body: buildBody(notificationData, state,context),
        );
      },
    );
  }
}