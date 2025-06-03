import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:flutter/material.dart';

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
      color: const Color(0xFFE8F5E9),
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
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1DE9B6),
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
class ChatInputBarFinance extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  const ChatInputBarFinance({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isSending,
              decoration: InputDecoration(
                hintText: isSending ? 'Đang gửi...' : 'Nhập nội dung...',
              ),
              onSubmitted: (_) {
                if (!isSending) onSend();
              },
            ),
          ),
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSending ? Colors.grey : AppColors.oceanBlue,
                borderRadius: BorderRadius.circular(18),
              ),
              child:
              isSending
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
