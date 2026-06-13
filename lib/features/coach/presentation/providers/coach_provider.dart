import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_wellness_tracker/features/coach/domain/entities/chat_message.dart';
import 'package:mental_wellness_tracker/features/coach/domain/repositories/coach_repository.dart';
import 'package:mental_wellness_tracker/core/providers/core_providers.dart';

final coachProvider = StateNotifierProvider<CoachNotifier, AsyncValue<List<ChatMessage>>>((ref) {
  final repo = ref.watch(coachRepositoryProvider);
  return CoachNotifier(repo);
});

class CoachNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final CoachRepository _repository;

  CoachNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadChat();
  }

  Future<void> loadChat() async {
    try {
      final chat = await _repository.getChatHistory();
      state = AsyncValue.data(chat);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendMessage(String text, Map<String, dynamic> studentProfile) async {
    final currentChat = state.valueOrNull ?? [];
    
    // Optimistic user update
    final tempUserMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user',
      text: text,
      timestamp: DateTime.now(),
    );
    
    state = AsyncValue.data([...currentChat, tempUserMsg]);

    try {
      await _repository.sendMessage(text, studentProfile);
      
      // Reload final state from repository to ensure sync
      final updatedChat = await _repository.getChatHistory();
      state = AsyncValue.data(updatedChat);
    } catch (e) {
      // Revert user message and show error state or display error message inside chat
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: 'coach',
        text: 'Sorry, I couldn\'t generate a reply. Please verify your Gemini API key in Settings.',
        timestamp: DateTime.now(),
      );
      state = AsyncValue.data([...currentChat, tempUserMsg, errorMsg]);
    }
  }

  Future<void> clearChat() async {
    state = const AsyncValue.loading();
    try {
      await _repository.clearChatHistory();
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
