import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
class NotificationModel extends Equatable {
  final String id;
  final String iconPath;
  final String title;
  final String subtitle;
  final String time;
  final String date;

  NotificationModel({
    String? id,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.date,
  }) : id = id ?? const Uuid().v4();

  static final List<NotificationModel> _notifications = [];

  static List<NotificationModel> getNotifications() => _notifications;

  static void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification); // Add to the top
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'iconPath': iconPath,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'date': date,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String? ?? const Uuid().v4(),
      iconPath: map['iconPath'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      time: map['time'] as String,
      date: map['date'] as String,
    );
  }

  @override
  List<Object> get props => [id, iconPath, title, subtitle, time, date];
}