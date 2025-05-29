import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/data/model/chat/chat_room_model.dart';
import 'package:finance_management/data/model/chat/chat_message_model.dart';

class FirebaseChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tạo hoặc lấy phòng chat cho user (mỗi user chỉ có 1 phòng chat với helper)
  Future<ChatRoomModel> createOrGetChatRoomForUser(String userId) async {
    // Kiểm tra xem user đã có phòng chat chưa
    final existingRooms =
        await _firestore
            .collection('chats')
            .where('userId', isEqualTo: userId)
            .get();

    if (existingRooms.docs.isNotEmpty) {
      // Nếu đã có phòng chat, trả về phòng chat đầu tiên
      return ChatRoomModel.fromMap(
        existingRooms.docs.first.data(),
        existingRooms.docs.first.id,
      );
    }

    // Nếu chưa có phòng chat, tạo phòng mới
    final docRef = await _firestore.collection('chats').add({
      'userId': userId,
      'helperId': null, // Chưa có helper nhận
      'lastMessage': '',
      'lastTimestamp': Timestamp.now(),
      'isActive': true,
    });
    final chatRoom = ChatRoomModel(
      id: docRef.id,
      userId: userId,
      helperId: null, // Chưa có helper nhận
      lastMessage: '',
      lastTimestamp: Timestamp.now(),
      isActive: true,
    );
    return chatRoom;
  }

  // Gửi tin nhắn
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String text,
  }) async {
    final messageRef =
        _firestore
            .collection('chats')
            .doc(chatRoomId)
            .collection('messages')
            .doc();
    final message = ChatMessageModel(
      id: messageRef.id,
      senderId: senderId,
      text: text,
      timestamp: Timestamp.now(),
    );
    await messageRef.set(message.toMap());
    // Update last message in chat room
    await _firestore.collection('chats').doc(chatRoomId).update({
      'lastMessage': text,
      'lastTimestamp': Timestamp.now(),
    });
  }

  // Lắng nghe tin nhắn realtime
  Stream<List<ChatMessageModel>> messagesStream(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Lắng nghe danh sách phòng chat cho helper (bao gồm cả đã end)
  Stream<List<ChatRoomModel>> chatRoomsForHelperStream({String? helperId}) {
    Query query = _firestore.collection('chats');
    if (helperId != null) {
      query = query.where('helperId', isEqualTo: helperId);
    } else {
      query = query.where('helperId', isNull: true);
    }
    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) => ChatRoomModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
    );
  }

  // Helper nhận chat (claim chat)
  Future<void> claimChat({
    required String chatRoomId,
    required String helperId,
  }) async {
    await _firestore.collection('chats').doc(chatRoomId).update({
      'helperId': helperId,
    });
  }

  // Lắng nghe danh sách phòng chat cho user (bao gồm cả đã end)
  Stream<List<ChatRoomModel>> chatRoomsForUserStream(String userId) {
    return _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatRoomModel.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }
}
