import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/coach_repository.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/errors/failures.dart';

class CoachRepositoryImpl implements CoachRepository {
  final StorageService _storageService;
  final GeminiService _geminiService;

  CoachRepositoryImpl(this._storageService, this._geminiService);

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    try {
      final list = _storageService.getChatHistory();
      return list.map((e) => ChatMessage.fromJson(e)).toList();
    } catch (e) {
      throw CacheFailure('Failed to load chat history: $e');
    }
  }

  @override
  Future<ChatMessage> sendMessage(String text, Map<String, dynamic> studentProfile) async {
    try {
      final history = await getChatHistory();
      
      // User message
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: 'user',
        text: text,
        timestamp: DateTime.now(),
      );

      // Map history to Gemini Content structures
      final List<Content> geminiHistory = [];
      for (final msg in history) {
        if (msg.sender == 'user') {
          geminiHistory.add(Content.text(msg.text));
        } else {
          geminiHistory.add(Content.model([TextPart(msg.text)]));
        }
      }

      // Generate response from Gemini
      final responseText = await _geminiService.chatCoach(
        geminiHistory,
        text,
        studentProfile,
      );

      // Coach message
      final coachMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        sender: 'coach',
        text: responseText,
        timestamp: DateTime.now(),
      );

      // Save user & coach messages
      final updatedList = [...history, userMessage, coachMessage];
      await _storageService.saveChatHistory(updatedList.map((e) => e.toJson()).toList());

      return coachMessage;
    } catch (e) {
      throw GeminiFailure('Failed to communicate with wellness coach: $e');
    }
  }

  @override
  Future<void> clearChatHistory() async {
    try {
      await _storageService.clearChatHistory();
    } catch (e) {
      throw CacheFailure('Failed to clear chat history: $e');
    }
  }
}
