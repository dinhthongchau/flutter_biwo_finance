import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:finance_management/data/model/chat_history/chat_history_model.dart';
import 'package:finance_management/data/model/chat_history/chat_history_storage.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_help/profile_online_support_ai_lobby.dart';

import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:finance_management/presentation/screens/authentication/profile/profile_help/profile_online_support_helper_center_screen.dart';
import 'package:finance_management/core/utils/notification_helper.dart';

class ProfileOnlineSupportAiScreen extends StatefulWidget {
  static const String routeName = '/profile-online-support-ai';
  final ChatHistory? chatHistory;
  const ProfileOnlineSupportAiScreen({super.key, this.chatHistory});

  @override
  State<ProfileOnlineSupportAiScreen> createState() =>
      _ProfileOnlineSupportAiScreenState();
}

class _ProfileOnlineSupportAiScreenState
    extends State<ProfileOnlineSupportAiScreen> {
  late List<_ChatMessage> _messages;
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  DateTime? _lastMessageTime;
  int _selectedTab = 0; // 0: Support Assistant

  final String geminiApiKey = 'AIzaSyBjIkKHpPonJbuIABGEIBNxHs19WpppSIY';

  @override
  void initState() {
    super.initState();
    if (widget.chatHistory != null) {
      _messages = [
        _ChatMessage(
          text: widget.chatHistory!.message,
          isBot: true,
          time: widget.chatHistory!.time,
        ),
      ];
    } else {
      _messages = [
        _ChatMessage(
          text: 'Welcome, I am your virtual assistant.',
          isBot: true,
          time: _formatTime(DateTime.now()),
        ),
        _ChatMessage(
          text: 'How can I help you today?',
          isBot: true,
          time: _formatTime(DateTime.now()),
        ),
      ];
    }
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Future<String> fetchGeminiReply(String userMsg, String apiKey) async {
    if (apiKey.isEmpty) {
      throw Exception(
        'Vui lòng cấu hình API key Gemini tại https://aistudio.google.com/app/apikey',
      );
    }

    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': userMsg},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'].trim();
      } else {
        final error = jsonDecode(response.body);
        if (error['error']['code'] == 429) {
          throw Exception(
            'Đã hết quota miễn phí. Vui lòng thử lại sau 24h hoặc tạo API key mới.',
          );
        }
        throw Exception('Lỗi Gemini: ${error['error']['message']}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('Không có kết nối internet. Vui lòng kiểm tra lại.');
      }
      rethrow;
    }
  }

  void _sendMessage() async {
    final now = DateTime.now();
    if (_lastMessageTime != null &&
        now.difference(_lastMessageTime!).inSeconds < 2) {
      return;
    }
    _lastMessageTime = now;

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_messages.isNotEmpty &&
        _messages.last.text == text &&
        !_messages.last.isBot) {
      return;
    }

    setState(() {
      _messages.add(
        _ChatMessage(text: text, isBot: false, time: _formatTime(now)),
      );
      _controller.clear();
      _isSending = true;
    });

    try {
      if (geminiApiKey.isEmpty) {
        throw Exception('Chưa cấu hình API key Gemini trong file .env!');
      }
      final aiReply = await fetchGeminiReply(text, geminiApiKey);
      if (mounted) {
        setState(() {
          _messages.add(
            _ChatMessage(
              text: aiReply,
              isBot: true,
              time: _formatTime(DateTime.now()),
            ),
          );
          _isSending = false;
        });

        final chatTitle = 'Support Assistant';
        await ChatHistoryStorage.saveChat(
          ChatHistory(
            title: chatTitle,
            message: aiReply,
            time: DateTime.now().toIso8601String(),
            isActive: true,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            _ChatMessage(
              text: 'Lỗi: $e',
              isBot: true,
              time: _formatTime(DateTime.now()),
            ),
          );
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.honeydew,
      appBar: AppBar(
        backgroundColor: AppColors.caribbeanGreen,
        title: const Text(
          'Online Support',
          style: TextStyle(
            color: AppColors.blackHeader,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.blackHeader),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blackHeader),
          onPressed:
              () => context.go(ProfileOnlineSupportAiLobbyScreen.routeName),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.blackHeader,
            ),
            onPressed: () {},
          ),
          if (widget.chatHistory != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'End Chat',
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => Center(
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 32,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'End Chat',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Are you sure you want to end this chat?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.caribbeanGreen,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final endedChat = ChatHistory(
                                        title: widget.chatHistory!.title,
                                        message: widget.chatHistory!.message,
                                        time: widget.chatHistory!.time,
                                        isActive: false,
                                      );
                                      await ChatHistoryStorage.saveChat(
                                        endedChat,
                                      );

                                      await ChatHistoryStorage.deleteActiveChat(
                                        widget.chatHistory!,
                                      );

                                      if (context.mounted) {
                                        context.pop();
                                        context.go(
                                          '/profile-online-support-ai-lobby',
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Yes, End Chat',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.caribbeanGreen,
                                      side: const BorderSide(
                                        color: AppColors.caribbeanGreen,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    onPressed: () => context.pop(),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _TabSelector(
            selectedTab: _selectedTab,
            onTabChanged: (tab) {
              if (tab == 1) {
                context.go(ProfileOnlineSupportHelperCenterScreen.routeName);
              } else {
                setState(() => _selectedTab = tab);
              }
            },
            showHelpCenter: true,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                if (msg.isBot && i == _messages.length - 1) {
                  NotificationHelper.show('New message', msg.text);
                }
                return ChatBubble(
                  text: msg.text,
                  isBot: msg.isBot,
                  time: msg.time,
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
}

class _TabSelector extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final bool showHelpCenter;
  const _TabSelector({
    required this.selectedTab,
    required this.onTabChanged,
    this.showHelpCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFD6F5E6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                      selectedTab == 0
                          ? AppColors.caribbeanGreen
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Support Assistant',
                    style: TextStyle(
                      color:
                          selectedTab == 0
                              ? Colors.white
                              : AppColors.blackHeader,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showHelpCenter)
            Expanded(
              child: GestureDetector(
                onTap: () => onTabChanged(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        selectedTab == 1
                            ? AppColors.caribbeanGreen
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Help Center',
                      style: TextStyle(
                        color:
                            selectedTab == 1
                                ? Colors.white
                                : AppColors.blackHeader,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TypeWriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;

  const TypeWriterText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 50),
  });

  @override
  State<TypeWriterText> createState() => _TypeWriterTextState();
}

class _TypeWriterTextState extends State<TypeWriterText> {
  String _displayText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayText, style: widget.style);
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isBot;
  final String? time;
  const ChatBubble({
    required this.text,
    required this.isBot,
    this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot) ...[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                        bottomRight: Radius.circular(22),
                      ),
                    ),
                    child: TypeWriterText(
                      text: text,
                      style: const TextStyle(
                        color: AppColors.blackHeader,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ] else ...[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.caribbeanGreen,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                        bottomLeft: Radius.circular(22),
                      ),
                    ),
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback? onSend;
  const ChatInputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.honeydew,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD6F5E6), width: 1.2),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: AppColors.caribbeanGreen,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Write Here...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) {
                        if (!isSending && onSend != null) onSend!();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.mic,
                      color: AppColors.caribbeanGreen,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.caribbeanGreen,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon:
                  isSending
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.send, color: Colors.white),
              onPressed: isSending ? null : onSend,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isBot;
  final String? time;
  _ChatMessage({required this.text, required this.isBot, this.time});
}
