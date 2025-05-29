import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image }

class ChatImageModel {
  final String id;
  final String senderId;
  final String? text;
  final String? imageUrl;
  final MessageType type;
  final Timestamp timestamp;
  final bool isHelper;

  ChatImageModel({
    required this.id,
    required this.senderId,
    this.text,
    this.imageUrl,
    required this.type,
    required this.timestamp,
    required this.isHelper,
  });

  factory ChatImageModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatImageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'],
      imageUrl: map['imageUrl'],
      type: map['type'] == 'image' ? MessageType.image : MessageType.text,
      timestamp: map['timestamp'] ?? Timestamp.now(),
      isHelper: map['isHelper'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'type': type == MessageType.image ? 'image' : 'text',
      'timestamp': timestamp,
      'isHelper': isHelper,
    };
  }
}
