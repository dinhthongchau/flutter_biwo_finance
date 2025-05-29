import 'package:flutter/material.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_help/profile_online_support_ai_screen.dart';
import 'package:finance_management/data/model/online_ai/chat_history_model.dart';
import 'package:finance_management/data/model/online_ai/chat_history_storage.dart';
import 'package:go_router/go_router.dart';

class ProfileOnlineSupportAiLobbyScreen extends StatefulWidget {
  static const String routeName = '/profile-online-support-ai-lobby';
  const ProfileOnlineSupportAiLobbyScreen({super.key});

  @override
  State<ProfileOnlineSupportAiLobbyScreen> createState() =>
      _ProfileOnlineSupportAiLobbyScreenState();
}

class _ProfileOnlineSupportAiLobbyScreenState
    extends State<ProfileOnlineSupportAiLobbyScreen> {
  late Future<List<ChatHistory>> _futureChats;

  @override
  void initState() {
    super.initState();
    _futureChats = ChatHistoryStorage.getChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.honeydew,
      appBar: AppBar(
        backgroundColor: AppColors.caribbeanGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blackHeader),
          onPressed: () => context.go('/profile-help-faqs'),
        ),
        title: const Text(
          'Online Support',
          style: TextStyle(
            color: AppColors.blackHeader,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.blackHeader,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: FutureBuilder<List<ChatHistory>>(
          future: _futureChats,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final chats = snapshot.data ?? [];
            final activeChats = chats.where((c) => c.isActive).toList();
            final endedChats = chats.where((c) => !c.isActive).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Active Chats',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (activeChats.isEmpty)
                        const Text(
                          'No active chats',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ...activeChats.map(
                        (chat) => ChatCard(
                          chat: chat,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ProfileOnlineSupportAiScreen(
                                      chatHistory: chat,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ended Chats',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (endedChats.isEmpty)
                        const Text(
                          'No ended chats',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ...endedChats.map(
                        (chat) => ChatCard(
                          chat: chat,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ProfileOnlineSupportAiScreen(
                                      chatHistory: chat,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.caribbeanGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileOnlineSupportAiScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Start Another Chat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  final ChatHistory chat;
  final VoidCallback onTap;
  const ChatCard({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: (0.6 * 255).round().toDouble()),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.caribbeanGreen.withValues(
                  alpha: (0.2 * 255).round().toDouble(),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: const Icon(
                Icons.headset_mic,
                color: AppColors.caribbeanGreen,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chat.message,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              chat.time,
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
