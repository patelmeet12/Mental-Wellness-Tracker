import '../entities/chat_message.dart';

abstract class CoachRepository {
  Future<List<ChatMessage>> getChatHistory();
  Future<ChatMessage> sendMessage(String text, Map<String, dynamic> studentProfile);
  Future<void> clearChatHistory();
}
