import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_management/data/model/online_ai/chat_history_model.dart';

class ChatHistoryStorage {
  static const String _key = 'chat_history';

  static Future<void> saveChat(ChatHistory chat) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> chats = prefs.getStringList(_key) ?? [];
    chats.insert(0, ChatHistory.encodeList([chat])); // mới nhất lên đầu
    await prefs.setStringList(_key, chats);
  }

  static Future<List<ChatHistory>> getChats() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> chats = prefs.getStringList(_key) ?? [];
    // Mỗi phần tử là 1 json list, chỉ lấy phần tử đầu tiên của mỗi list
    return chats.map((e) => ChatHistory.decodeList(e).first).toList();
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> deleteActiveChat(ChatHistory chat) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> chats = prefs.getStringList(_key) ?? [];

    // Lọc ra các chat không phải là chat cần xóa
    final updatedChats =
        chats.where((chatJson) {
          final chatList = ChatHistory.decodeList(chatJson);
          final existingChat = chatList.first;
          return !(existingChat.title == chat.title &&
              existingChat.message == chat.message &&
              existingChat.time == chat.time &&
              existingChat.isActive);
        }).toList();

    await prefs.setStringList(_key, updatedChats);
  }
}
