import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final String userId;
  final String? helperId;
  final String lastMessage;
  final Timestamp lastTimestamp;
  final bool isActive;

  ChatRoomModel({
    required this.id,
    required this.userId,
    this.helperId,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.isActive,
  });

  factory ChatRoomModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoomModel(
      id: id,
      userId: map['userId'] ?? '',
      helperId: map['helperId'],
      lastMessage: map['lastMessage'] ?? '',
      lastTimestamp: map['lastTimestamp'] ?? Timestamp.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'helperId': helperId,
      'lastMessage': lastMessage,
      'lastTimestamp': lastTimestamp,
      'isActive': isActive,
    };
  }
}
