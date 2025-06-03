import 'dart:convert';

import 'package:finance_management/data/repositories/user_repository.dart';
import 'package:finance_management/presentation/screens/chatbot_finance/chatbot_finance_prompt.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:finance_management/presentation/widgets/chat_bubble.dart'
    as widget;
import 'package:finance_management/presentation/widgets/chat_bubble.dart';
import 'package:finance_management/presentation/widgets/chat_input_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

mixin ChatbotFinanceScreenMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isSending = false;

  // Gemini API Key (load from .env)
  final String geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  // Show usage instructions dialog
  void showInfoDialog(BuildContext context) {
    DialogUtils.isConfirmDialog(
      context,
      title: 'Hướng dẫn dùng AI Money',
      message: ChatbotFinancePrompt.dialogInfoAppBar(),
      onConfirm: () => Navigator.pop(context),
      confirmText: 'OK',
      cancelText: 'Hủy',
    );
  }

  // Kiểm tra và tạo danh mục nếu không tồn tại trong Firestore
  Future<CategoryModel> _ensureCategoryExists(
    BuildContext context,
    String userId,
    String categoryType,
    MoneyType moneyType,
  ) async {
    final categoryRepo = CategoryRepository();
    final categories = await categoryRepo.getCategories(userId);
    final targetCategory = categories.firstWhere(
      (cat) => cat.categoryType == categoryType && cat.moneyType == moneyType,
      orElse:
          () => CategoryModel(
            int.parse(const Uuid().v4().hashCode.toString().substring(0, 8)),
            moneyType,
            categoryType,
          ),
    );
    if (!categories.contains(targetCategory)) {
      context.read<CategoryBloc>().add(AddCategory(targetCategory));
    }
    return targetCategory;
  }

  // Call Gemini API to process user input
  Future<Map<String, dynamic>> _processWithGemini(String input) async {
    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': ChatbotFinancePrompt.analyzeCommand(input),
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rawText = data['candidates'][0]['content']['parts'][0]['text'];
      debugPrint('Gemini rawText: $rawText');
      final cleaned = rawText.replaceAll(RegExp(r'```json|```'), '').trim();
      try {
        return jsonDecode(cleaned);
      } catch (e) {
        debugPrint('JSON parse error: $e');
        _messages.add({
          'text':
              'Yêu cầu chưa rõ ràng hoặc không hợp lệ, vui lòng nhập lại câu hỏi/giao dịch rõ ràng hơn!',
          'isSender': false,
        });
        throw Exception('Lỗi định dạng JSON từ Gemini.');
      }
    } else {
      throw Exception('Lỗi Gemini API: ${response.statusCode}');
    }
  }

  // Handle Gemini API response and dispatch Bloc events
  Future<void> _handleGeminiResponse(
    BuildContext context,
    Map<String, dynamic> response,
  ) async {
    final action = response['action'];
    final params = response['params'];
    final uuid = Uuid();
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) return;

    final user = await UserRepository().getUserById(authUser.uid);
    if (user == null) return;

    try {
      switch (action) {
        case 'add_transaction':
          final rawAmount = params['amount'];
          int amount =
              rawAmount is int
                  ? rawAmount
                  : (rawAmount is String
                      ? int.tryParse(rawAmount) ?? 0
                      : (rawAmount is double ? rawAmount.toInt() : 0));

          final transactionType = params['transaction_type'] ?? 'expense';
          final categoryType =
              params['category'] ??
              (transactionType == 'income' ? 'Salary' : 'Transport');
          final title = params['title'] ?? categoryType;

          // Kiểm tra tiêu đề hợp lệ
          if (title.trim().length < 2 ||
              RegExp(r'^[^a-zA-Z0-9]+$').hasMatch(title.trim())) {
            _messages.add({
              'text':
                  'Tiêu đề không hợp lệ, vui lòng nhập lại nội dung rõ ràng hơn!',
              'isSender': false,
            });
            return;
          }

          // Kiểm tra amount hợp lệ
          if (amount <= 0) {
            _messages.add({
              'text': 'Số tiền không hợp lệ, vui lòng nhập số tiền lớn hơn 0!',
              'isSender': false,
            });
            return;
          }

          // Đảm bảo danh mục tồn tại
          final category = await _ensureCategoryExists(
            context,
            authUser.uid,
            categoryType,
            transactionType == 'income' ? MoneyType.income : MoneyType.expense,
          );

          final transaction = TransactionModel(
            user,
            int.parse(uuid.v4().hashCode.toString().substring(0, 8)),
            DateTime.now(),
            amount,
            category,
            title,
            params['note'] ?? '',
          );

          context.read<TransactionBloc>().add(AddTransactionEvent(transaction));

          // Tùy chỉnh thông báo
          final message =
              transactionType == 'income'
                  ? 'Tôi đã cộng ${amount}\$ với nội dung: ${categoryType == 'Salary' ? 'Lãnh lương tháng' : title}'
                  : 'Tôi đã trừ ${amount}\$ với nội dung: ${categoryType == 'Transport' ? 'Phương tiện xe buýt' : title}';
          _messages.add({'text': message, 'isSender': false});
          break;

        case 'edit_transaction':
          final categoryType = params['category'] ?? 'Other Expense';
          final category = await _ensureCategoryExists(
            context,
            authUser.uid,
            categoryType,
            params['type'] == 'income' ? MoneyType.income : MoneyType.expense,
          );
          final transaction = TransactionModel(
            user,
            int.parse(
              params['id'] ?? uuid.v4().hashCode.toString().substring(0, 8),
            ),
            DateTime.parse(params['date'] ?? DateTime.now().toIso8601String()),
            (double.parse(params['amount'] ?? '0') * 1000).toInt(),
            category,
            params['title'] ?? 'Giao dịch',
            params['note'] ?? '',
          );
          context.read<TransactionBloc>().add(
            EditTransactionEvent(transaction),
          );
          _messages.add({
            'text': 'Đã chỉnh sửa giao dịch: ${params['title']}',
            'isSender': false,
          });
          break;

        case 'delete_transaction':
          context.read<TransactionBloc>().add(
            DeleteTransactionEvent(params['id']),
          );
          _messages.add({'text': 'Đã xóa giao dịch', 'isSender': false});
          break;

        case 'add_category':
          final category = CategoryModel(
            int.parse(uuid.v4().hashCode.toString().substring(0, 8)),
            params['type'] == 'income' ? MoneyType.income : MoneyType.expense,
            params['name'] ?? 'Other',
          );
          context.read<CategoryBloc>().add(AddCategory(category));
          _messages.add({
            'text': 'Đã thêm danh mục: ${params['name']}',
            'isSender': false,
          });
          break;

        default:
          _messages.add({
            'text':
                'Yêu cầu chưa rõ ràng hoặc không hợp lệ, vui lòng nhập lại!',
            'isSender': false,
          });
      }
    } catch (e, stack) {
      debugPrint('Chatbot error: $e\n$stack');
      _messages.add({
        'text':
            'Đã xảy ra lỗi khi xử lý yêu cầu. Vui lòng nhập lại hoặc thử câu khác!',
        'isSender': false,
      });
    }
  }

  // Build main chat UI
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocConsumer<TransactionBloc, TransactionState>(
            listener: (context, state) {
              if (state is TransactionError) {
                SnackbarUtils.showNoticeSnackbar(
                  context,
                  state.errorMessage ?? 'Lỗi không xác định',
                  true,
                );
              }
            },
            builder: (context, state) {
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatBubbleFinance(
                    text: message['text'],
                    isSender: message['isSender'],
                    time: DateFormat('HH:mm').format(DateTime.now()),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 10,
          ),
          child: ChatInputBarFinance(
            controller: _inputController,
            isSending: _isSending,
            onSend: () async {
              final message = _inputController.text.trim();
              if (message.isNotEmpty && !_isSending) {
                _messages.add({'text': message, 'isSender': true});
                _inputController.clear();
                _isSending = true;
                // Thêm message loading
                _messages.add({
                  'text': '... đang load',
                  'isSender': false,
                  'isLoading': true,
                });

                try {
                  final response = await _processWithGemini(message);
                  // Xóa message loading
                  _messages.removeWhere((msg) => msg['isLoading'] == true);
                  await _handleGeminiResponse(context, response);
                } catch (e) {
                  _messages.removeWhere((msg) => msg['isLoading'] == true);
                  SnackbarUtils.showNoticeSnackbar(context, 'Lỗi: $e', true);
                  _messages.add({
                    'text': 'Lỗi khi xử lý: $e',
                    'isSender': false,
                  });
                }
                _isSending = false;

                // Scroll to bottom
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              } else {
                SnackbarUtils.showNoticeSnackbar(
                  context,
                  'Vui lòng nhập nội dung.',
                  true,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}


