import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/ai/workout_planner_client.dart';
import '../data/local/app_database.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/workout_conversation.dart';
import 'app_providers.dart';
import 'locale_provider.dart';

const _uuid = Uuid();

class WorkoutPlannerState {
  const WorkoutPlannerState({
    this.conversations = const [],
    this.currentMessages = const [],
    this.isLoading = false,
  });

  final List<WorkoutConversation> conversations;
  final List<ChatMessage> currentMessages;
  final bool isLoading;

  WorkoutPlannerState copyWith({
    List<WorkoutConversation>? conversations,
    List<ChatMessage>? currentMessages,
    bool? isLoading,
  }) {
    return WorkoutPlannerState(
      conversations: conversations ?? this.conversations,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WorkoutPlannerNotifier extends StateNotifier<WorkoutPlannerState> {
  WorkoutPlannerNotifier(this._client, this._ref)
      : super(const WorkoutPlannerState()) {
    _loadConversations();
  }

  final WorkoutPlannerClient _client;
  final Ref _ref;

  Future<void> _loadConversations() async {
    final db = AppDatabase.instance;
    final conversations = await db.getConversations();
    state = state.copyWith(conversations: conversations);
  }

  Future<void> createConversation(WorkoutConversation conversation) async {
    final db = AppDatabase.instance;
    await db.saveConversation(conversation);
    await _loadConversations();
  }

  Future<void> loadMessages(String conversationId) async {
    final db = AppDatabase.instance;
    final messages = await db.getMessages(conversationId);
    state = state.copyWith(currentMessages: messages);
  }

  void clearCurrentMessages() {
    state = state.copyWith(currentMessages: []);
  }

  Future<void> addMessage(ChatMessage message) async {
    final db = AppDatabase.instance;
    await db.saveMessage(message);
    
    final conversation = await db.getConversation(message.conversationId);
    if (conversation != null) {
      await db.saveConversation(
        conversation.copyWith(updatedAt: DateTime.now()),
      );
    }
    
    state = state.copyWith(
      currentMessages: [...state.currentMessages, message],
    );
    await _loadConversations();
  }

  Future<void> generateResponse(String conversationId) async {
    try {
      final profile = _ref.read(profileProvider);
      final locale = _ref.read(localeProvider);
      final languageCode = locale?.languageCode ?? 'sv';
      
      final response = await _client.generateResponse(
        conversationHistory: state.currentMessages,
        userMessage: state.currentMessages.last.content,
        userProfile: profile,
        languageCode: languageCode,
      );

      if (response != null && response.isNotEmpty) {
        final assistantMessage = ChatMessage(
          id: _uuid.v4(),
          conversationId: conversationId,
          role: MessageRole.assistant,
          content: response,
          timestamp: DateTime.now(),
        );
        await addMessage(assistantMessage);
      }
    } catch (_) {
    }
  }

  Future<void> deleteConversation(String id) async {
    final db = AppDatabase.instance;
    await db.deleteConversation(id);
    await _loadConversations();
    
    if (state.currentMessages.isNotEmpty &&
        state.currentMessages.first.conversationId == id) {
      clearCurrentMessages();
    }
  }
}

final workoutPlannerClientProvider = Provider<WorkoutPlannerClient>((ref) {
  final client = WorkoutPlannerClient();
  ref.onDispose(client.dispose);
  return client;
});

final workoutPlannerProvider =
    StateNotifierProvider<WorkoutPlannerNotifier, WorkoutPlannerState>((ref) {
  final client = ref.watch(workoutPlannerClientProvider);
  return WorkoutPlannerNotifier(client, ref);
});
