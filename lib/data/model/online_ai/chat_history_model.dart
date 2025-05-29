import 'dart:convert';

class ChatHistory {
  final String title;
  final String message;
  final String time;
  final bool isActive;

  ChatHistory({
    required this.title,
    required this.message,
    required this.time,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'message': message,
    'time': time,
    'isActive': isActive,
  };

  factory ChatHistory.fromJson(Map<String, dynamic> json) => ChatHistory(
    title: json['title'],
    message: json['message'],
    time: json['time'],
    isActive: json['isActive'],
  );

  static String encodeList(List<ChatHistory> chats) =>
      jsonEncode(chats.map((e) => e.toJson()).toList());

  static List<ChatHistory> decodeList(String chats) =>
      (jsonDecode(chats) as List).map((e) => ChatHistory.fromJson(e)).toList();
}
