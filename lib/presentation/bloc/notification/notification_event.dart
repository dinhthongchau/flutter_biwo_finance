import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationReceived extends NotificationEvent {}

class NotificationRead extends NotificationEvent {}
