import 'package:flutter/material.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management/data/services/firebase_chat_service.dart';
import 'package:finance_management/data/model/chat/chat_room_model.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_help/profile_online_support_helper_chat_screen.dart';

class ProfileOnlineSupportHelperScreen extends StatefulWidget {
  static const String routeName = '/profile-online-support-helper';
  const ProfileOnlineSupportHelperScreen({super.key});

  @override
  State<ProfileOnlineSupportHelperScreen> createState() =>
      _ProfileOnlineSupportHelperScreenState();
}

class _ProfileOnlineSupportHelperScreenState
    extends State<ProfileOnlineSupportHelperScreen> {
  final _chatService = FirebaseChatService();
  String? _helperId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _helperId = user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.honeydew,
      appBar: AppBar(
        backgroundColor: AppColors.caribbeanGreen,
        title: const Text(
          'Support Chats',
          style: TextStyle(
            color: AppColors.blackHeader,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.blackHeader),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/login-screen');
              }
            },
          ),
        ],
      ),
      body:
          _helperId == null
              ? const Center(child: Text('Not logged in'))
              : StreamBuilder<List<ChatRoomModel>>(
                stream: _chatService.chatRoomsForHelperStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final waitingChats = snapshot.data!;
                  return StreamBuilder<List<ChatRoomModel>>(
                    stream: _chatService.chatRoomsForHelperStream(
                      helperId: _helperId,
                    ),
                    builder: (context, snapshot2) {
                      final myChats = snapshot2.data ?? [];
                      final allChats = [...waitingChats, ...myChats];
                      if (allChats.isEmpty) {
                        return const Center(child: Text('No chats available.'));
                      }
                      return ListView.builder(
                        itemCount: allChats.length,
                        itemBuilder: (context, i) {
                          final chat = allChats[i];
                          final isClaimed = chat.helperId == _helperId;
                          return ListTile(
                            title: Text('User: ${chat.userId}'),
                            subtitle: Text(chat.lastMessage),
                            trailing:
                                isClaimed
                                    ? const Icon(
                                      Icons.verified_user,
                                      color: Colors.green,
                                    )
                                    : const Icon(
                                      Icons.hourglass_empty,
                                      color: Colors.orange,
                                    ),
                            onTap: () async {
                              if (!isClaimed) {
                                await _chatService.claimChat(
                                  chatRoomId: chat.id,
                                  helperId: _helperId!,
                                );
                              }
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            ProfileOnlineSupportHelperChatScreen(
                                              chatRoom: chat,
                                              helperId: _helperId!,
                                            ),
                                  ),
                                );
                                // context.go('/profile-online-support-helper-chat', extra: {
                                //   'chatRoom': chat,
                                //   'helperId': _helperId!,
                                // });
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
