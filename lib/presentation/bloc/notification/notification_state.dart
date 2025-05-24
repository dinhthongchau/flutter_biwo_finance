import 'package:equatable/equatable.dart';
import 'package:finance_management/data/model/notification_model.dart';

abstract class NotificationState extends Equatable {
  final List<NotificationModel>? notifications;
  final int? notificationCount;
  final String? errorMessage;

  const NotificationState({
    this.notifications,
    this.notificationCount,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [notifications, notificationCount, errorMessage];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial({super.notifications, super.notificationCount = 0});
}

class NotificationLoading extends NotificationState {
  const NotificationLoading({super.notifications, super.notificationCount});

  NotificationLoading.fromState({required NotificationState state})
      : super(
    notifications: state.notifications,
    notificationCount: state.notificationCount,
  );
}

class NotificationSuccess extends NotificationState {
  const NotificationSuccess({super.notifications, super.notificationCount});
}

class NotificationError extends NotificationState {
  const NotificationError({
    super.notifications,
    super.notificationCount,
    required String super.errorMessage,
  });
}