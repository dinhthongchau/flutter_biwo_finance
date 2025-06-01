import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/presentation/widgets/chat_bubble.dart';
import 'package:finance_management/presentation/widgets/chat_input_bar.dart';
import 'package:finance_management/data/services/firebase_chat_service.dart';
import 'package:finance_management/data/model/chat/chat_message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_management/core/utils/notification_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_help/profile_online_support_ai_lobby.dart';

class ProfileOnlineSupportHelperCenterScreen extends StatefulWidget {
  static const String routeName = '/profile-online-support-helper-center';
  const ProfileOnlineSupportHelperCenterScreen({super.key});

  @override
  State<ProfileOnlineSupportHelperCenterScreen> createState() =>
      _ProfileOnlineSupportHelperCenterScreenState();
}

class _ProfileOnlineSupportHelperCenterScreenState
    extends State<ProfileOnlineSupportHelperCenterScreen> {
  final _chatService = FirebaseChatService();
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  String? _userId;
  String? _chatRoomId;
  // ChatRoomModel? _chatRoom; // Optional: for displaying info

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userId = user?.uid;
    final uri = Uri.base;
    if (uri.queryParameters.containsKey('chatRoomId')) {
      _chatRoomId = uri.queryParameters['chatRoomId'];
      _fetchChatRoomInfo(_chatRoomId!);
    } else {
      // Only create new room if not coming from notification
      if (_userId != null) {
        _createOrGetChatRoomForUser(_userId!);
      }
    }
  }

  Future<void> _fetchChatRoomInfo(String chatRoomId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatRoomId)
            .get();
    if (doc.exists) {
      setState(() {
        // _chatRoom = ChatRoomModel.fromMap(
        //   doc.data() as Map<String, dynamic>,
        //   doc.id,
        // );
      });
    }
  }

  Future<void> _createOrGetChatRoomForUser(String userId) async {
    final room = await _chatService.createOrGetChatRoomForUser(userId);
    setState(() {
      _chatRoomId = room.id;
      // _chatRoom = room;
    });
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty ||
        _isSending ||
        _chatRoomId == null ||
        _userId == null) {
      return;
    }
    setState(() => _isSending = true);
    try {
      await _chatService.sendMessage(
        chatRoomId: _chatRoomId!,
        senderId: _userId!,
        text: _controller.text.trim(),
      );
      _controller.clear();
    } catch (e) {
      // Handle error
    }
    setState(() => _isSending = false);
  }

  void _showNotification(String title, String body, {String? chatRoomId}) {
    NotificationHelper.show(title, body, chatRoomId: chatRoomId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chatRoomId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFE8F5E9),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1DE9B6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.go(ProfileOnlineSupportAiLobbyScreen.routeName);
          },
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              _showNotification(
                'New message',
                'You have a new message from helper',
                chatRoomId: _chatRoomId,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: _chatService.messagesStream(_chatRoomId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                if (messages.isNotEmpty) {
                  final lastMsg = messages.last;
                  if (lastMsg.senderId != _userId) {
                    _showNotification(
                      'New message',
                      lastMsg.text,
                      chatRoomId: _chatRoomId,
                    );
                    //!TODO later
                    // context.read<NotificationBloc>().add(
                    //   NotificationReceived(),
                    // );
                  }
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isSender = msg.senderId == _userId;
                    final time = _formatTime(msg.timestamp);
                    return ChatBubble(
                      text: msg.text,
                      isSender: isSender,
                      time: time,
                    );
                  },
                );
              },
            ),
          ),
          ChatInputBar(
            controller: _controller,
            isSending: _isSending,
            onSend: _isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
