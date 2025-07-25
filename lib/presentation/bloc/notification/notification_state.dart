import 'package:equatable/equatable.dart';
import 'package:finance_management/data/model/notification/notification_model.dart';

abstract class NotificationState extends Equatable {
  final List<NotificationModel>? notifications;
  final int? notificationCount;


  const NotificationState({
    this.notifications,
    this.notificationCount,
  });

  @override
  List<Object?> get props => [notifications, notificationCount];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial({super.notifications, super.notificationCount = 0});
  
  @override
  List<Object?> get props => [notifications, notificationCount];
}

class NotificationLoading extends NotificationState {
  const NotificationLoading({super.notifications, super.notificationCount});

  NotificationLoading.fromState({required NotificationState state})
      : super(
    notifications: state.notifications,
    notificationCount: state.notificationCount,
  );
  
  @override
  List<Object?> get props => [notifications, notificationCount];
}

class NotificationSuccess extends NotificationState {
  const NotificationSuccess({super.notifications, super.notificationCount});
  
  @override
  List<Object?> get props => [notifications, notificationCount];
}

class NotificationError extends NotificationState {
  final String? errorMessage;
  const NotificationError({
    super.notifications,
    super.notificationCount,
    required this.errorMessage,
  });
  
  @override
  List<Object?> get props => [notifications, notificationCount, errorMessage];
}