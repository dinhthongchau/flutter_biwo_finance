import 'package:equatable/equatable.dart';

class NotificationState extends Equatable {
  final bool hasNewMessage;
  const NotificationState({this.hasNewMessage = false});

  NotificationState copyWith({bool? hasNewMessage}) =>
      NotificationState(hasNewMessage: hasNewMessage ?? this.hasNewMessage);

  @override
  List<Object?> get props => [hasNewMessage];
}
