import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/ai/plan_generator_client.dart';
import '../data/ai/workout_planner_client.dart';
import '../data/local/app_database.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/custom_workout_plan.dart';
import '../domain/models/workout_conversation.dart';
import 'app_providers.dart';
import 'locale_provider.dart';

const _uuid = Uuid();

class WorkoutPlannerState {
  const WorkoutPlannerState({
    this.conversations = const [],
    this.currentMessages = const [],
    this.selectedConversationId,
    this.isLoading = false,
  });

  final List<WorkoutConversation> conversations;
  final List<ChatMessage> currentMessages;
  final String? selectedConversationId;
  final bool isLoading;

  WorkoutPlannerState copyWith({
    List<WorkoutConversation>? conversations,
    List<ChatMessage>? currentMessages,
    String? Function()? selectedConversationId,
    bool? isLoading,
  }) {
    return WorkoutPlannerState(
      conversations: conversations ?? this.conversations,
      currentMessages: currentMessages ?? this.currentMessages,
      selectedConversationId: selectedConversationId != null 
          ? selectedConversationId() 
          : this.selectedConversationId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WorkoutPlannerNotifier extends Notifier<WorkoutPlannerState> {
  late final WorkoutPlannerClient _client;
  late final PlanGeneratorClient _planGenerator;

  @override
  WorkoutPlannerState build() {
    _client = ref.watch(workoutPlannerClientProvider);
    _planGenerator = ref.watch(planGeneratorClientProvider);
    _loadConversations();
    return const WorkoutPlannerState();
  }

  Future<void> _loadConversations() async {
    final db = AppDatabase.instance;
    final conversations = await db.getConversations();
    state = state.copyWith(conversations: conversations);
  }

  Future<void> createConversation(WorkoutConversation conversation) async {
    final db = AppDatabase.instance;
    await db.saveConversation(conversation);
    await _loadConversations();
    state = state.copyWith(selectedConversationId: () => conversation.id);
  }

  Future<void> loadMessages(String conversationId) async {
    final db = AppDatabase.instance;
    final messages = await db.getMessages(conversationId);
    state = state.copyWith(
      currentMessages: messages,
      selectedConversationId: () => conversationId,
    );
  }

  void clearCurrentMessages() {
    state = state.copyWith(
      currentMessages: [],
      selectedConversationId: () => null,
    );
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
      final profile = ref.read(profileProvider);
      final locale = ref.read(localeProvider);
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

  Future<CustomWorkoutPlan?> generatePlanFromConversation(
    String conversationId,
  ) async {
    try {
      debugPrint('Starting plan generation for conversation: $conversationId');
      
      final profile = ref.read(profileProvider);
      final locale = ref.read(localeProvider);
      final languageCode = locale?.languageCode ?? 'sv';

      final plan = await _planGenerator.generatePlanFromConversation(
        conversationId: conversationId,
        conversationHistory: state.currentMessages,
        userProfile: profile,
        languageCode: languageCode,
      );
      
      if (plan == null) {
        debugPrint('Plan generation returned null');
      } else {
        debugPrint('Plan generated successfully: ${plan.name}');
      }
      
      return plan;
    } catch (e, stackTrace) {
      debugPrint('Error generating plan: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> savePlan(CustomWorkoutPlan plan) async {
    try {
      debugPrint('Saving custom plan: ${plan.name}');
      final db = AppDatabase.instance;
      await db.saveCustomPlan(plan);
      debugPrint('Custom plan saved successfully');
    } catch (e, stackTrace) {
      debugPrint('Error saving plan: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

final workoutPlannerClientProvider = Provider<WorkoutPlannerClient>((ref) {
  final client = WorkoutPlannerClient();
  ref.onDispose(client.dispose);
  return client;
});

final planGeneratorClientProvider = Provider<PlanGeneratorClient>((ref) {
  final client = PlanGeneratorClient();
  ref.onDispose(client.dispose);
  return client;
});

final workoutPlannerProvider =
    NotifierProvider<WorkoutPlannerNotifier, WorkoutPlannerState>(
  WorkoutPlannerNotifier.new,
);
