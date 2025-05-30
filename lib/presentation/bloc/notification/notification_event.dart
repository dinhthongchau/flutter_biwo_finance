import 'package:equatable/equatable.dart';
import 'package:finance_management/data/model/notification/notification_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class AddNotification extends NotificationEvent {
  final NotificationModel notification;

  const AddNotification(this.notification);

  @override
  List<Object?> get props => [notification];
}

class ClearNotifications extends NotificationEvent {
  const ClearNotifications();
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}