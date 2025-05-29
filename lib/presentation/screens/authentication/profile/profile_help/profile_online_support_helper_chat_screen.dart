import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/presentation/widgets/chat_bubble.dart';
import 'package:finance_management/presentation/widgets/chat_input_bar.dart';
import 'package:finance_management/data/services/firebase_chat_service.dart';
import 'package:finance_management/data/model/chat/chat_message_model.dart';
import 'package:finance_management/data/model/chat/chat_room_model.dart';

class ProfileOnlineSupportHelperChatScreen extends StatefulWidget {
  final ChatRoomModel chatRoom;
  final String helperId;
  const ProfileOnlineSupportHelperChatScreen({
    super.key,
    required this.chatRoom,
    required this.helperId,
  });

  @override
  State<ProfileOnlineSupportHelperChatScreen> createState() =>
      _ProfileOnlineSupportHelperChatScreenState();
}

class _ProfileOnlineSupportHelperChatScreenState
    extends State<ProfileOnlineSupportHelperChatScreen> {
  final _chatService = FirebaseChatService();
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isSending) return;
    setState(() => _isSending = true);
    await _chatService.sendMessage(
      chatRoomId: widget.chatRoom.id,
      senderId: widget.helperId,
      text: _controller.text.trim(),
    );
    _controller.clear();
    setState(() => _isSending = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1DE9B6),
        title: Text('Chat with User: ${widget.chatRoom.userId}'),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: _chatService.messagesStream(widget.chatRoom.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isSender = msg.senderId == widget.helperId;
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
