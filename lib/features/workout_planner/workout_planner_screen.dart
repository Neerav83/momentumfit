import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/chat_message.dart';
import '../../domain/models/workout_conversation.dart';
import '../../providers/workout_planner_provider.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/conversation_list_item.dart';

const _uuid = Uuid();

class WorkoutPlannerScreen extends ConsumerStatefulWidget {
  const WorkoutPlannerScreen({super.key});

  @override
  ConsumerState<WorkoutPlannerScreen> createState() =>
      _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends ConsumerState<WorkoutPlannerScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isGenerating) return;

    setState(() => _isGenerating = true);
    _messageController.clear();

    try {
      final state = ref.read(workoutPlannerProvider);
      String conversationId = state.selectedConversationId ?? _uuid.v4();
      
      if (state.selectedConversationId == null) {
        final title = text.length > 50 ? '${text.substring(0, 50)}...' : text;
        final conversation = WorkoutConversation(
          id: conversationId,
          title: title,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref
            .read(workoutPlannerProvider.notifier)
            .createConversation(conversation);
      }

      final userMessage = ChatMessage(
        id: _uuid.v4(),
        conversationId: conversationId,
        role: MessageRole.user,
        content: text,
        timestamp: DateTime.now(),
      );

      await ref
          .read(workoutPlannerProvider.notifier)
          .addMessage(userMessage);
      
      _scrollToBottom();

      await ref
          .read(workoutPlannerProvider.notifier)
          .generateResponse(conversationId);
      
      _scrollToBottom();
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _selectConversation(String id) {
    ref.read(workoutPlannerProvider.notifier).loadMessages(id);
  }

  void _startNewConversation() {
    ref.read(workoutPlannerProvider.notifier).clearCurrentMessages();
  }

  String? _getConversationTitle(List<WorkoutConversation> conversations, String? id) {
    if (id == null) return null;
    try {
      return conversations.firstWhere((c) => c.id == id).title;
    } catch (_) {
      return null;
    }
  }

  Future<void> _generatePlanFromConversation(WorkoutPlannerState state) async {
    if (state.selectedConversationId == null || state.currentMessages.isEmpty) {
      return;
    }

    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Skapar träningsplan från konversationen...'),
          ],
        ),
      ),
    );

    final plan = await ref
        .read(workoutPlannerProvider.notifier)
        .generatePlanFromConversation(state.selectedConversationId!);

    if (!mounted) return;
    Navigator.of(context).pop();

    if (plan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kunde inte skapa träningsplan. Försök igen.'),
        ),
      );
      return;
    }

    final shouldActivate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plan.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plan.description != null) ...[
              Text(plan.description!),
              const SizedBox(height: 16),
            ],
            Text(
              'Veckoschema:',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...plan.weeklySchedule.map((day) {
              final dayName = _getDayName(day.dayOfWeek);
              final exerciseCount = day.exercises.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  day.isRestDay
                      ? '$dayName: Vilodag'
                      : '$dayName: $exerciseCount övningar',
                  style: theme.textTheme.bodySmall,
                ),
              );
            }),
            const SizedBox(height: 16),
            const Text('Vill du aktivera denna träningsplan?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Spara utan att aktivera'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Aktivera'),
          ),
        ],
      ),
    );

    if (shouldActivate != null) {
      try {
        await ref
            .read(workoutPlannerProvider.notifier)
            .savePlan(plan.copyWith(isActive: shouldActivate));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                shouldActivate
                    ? 'Träningsplan aktiverad!'
                    : 'Träningsplan sparad',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fel vid sparande av träningsplan: $e'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    }
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Måndag';
      case 2:
        return 'Tisdag';
      case 3:
        return 'Onsdag';
      case 4:
        return 'Torsdag';
      case 5:
        return 'Fredag';
      case 6:
        return 'Lördag';
      case 7:
        return 'Söndag';
      default:
        return 'Dag $dayOfWeek';
    }
  }

  Future<void> _deleteConversation(String id) async {
    final state = ref.read(workoutPlannerProvider);
    await ref.read(workoutPlannerProvider.notifier).deleteConversation(id);
    if (id == state.selectedConversationId) {
      _startNewConversation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutPlannerProvider);
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.selectedConversationId == null
              ? 'Ny träningsplan'
              : _getConversationTitle(state.conversations, state.selectedConversationId) ?? 'Träningsplan',
        ),
        actions: [
          if (state.selectedConversationId != null && state.currentMessages.length >= 4)
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: () => _generatePlanFromConversation(state),
              tooltip: 'Skapa träningsplan',
            ),
          if (state.selectedConversationId != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _startNewConversation,
              tooltip: 'Ny konversation',
            ),
        ],
      ),
      body: isWide ? _buildWideLayout(state, theme) : _buildNarrowLayout(state, theme),
    );
  }

  Widget _buildWideLayout(WorkoutPlannerState state, ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: _buildConversationsList(state, theme),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _buildChatView(state, theme),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(WorkoutPlannerState state, ThemeData theme) {
    if (state.selectedConversationId == null && state.currentMessages.isEmpty) {
      return Column(
        children: [
          Expanded(child: _buildConversationsList(state, theme)),
          _buildMessageInput(theme),
        ],
      );
    }
    return _buildChatView(state, theme);
  }

  Widget _buildConversationsList(WorkoutPlannerState state, ThemeData theme) {
    if (state.conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Ingen träningsplan ännu',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Börja diskutera din träningsplan med AI-coachen',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: state.conversations.length,
      itemBuilder: (context, index) {
        final conversation = state.conversations[index];
        return ConversationListItem(
          conversation: conversation,
          isSelected: conversation.id == state.selectedConversationId,
          onTap: () => _selectConversation(conversation.id),
          onDelete: () => _deleteConversation(conversation.id),
        );
      },
    );
  }

  Widget _buildChatView(WorkoutPlannerState state, ThemeData theme) {
    final messages = state.currentMessages;

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyChat(theme)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (_isGenerating ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return ChatBubble(
                        message: ChatMessage(
                          id: 'temp',
                          conversationId: state.selectedConversationId ?? '',
                          role: MessageRole.assistant,
                          content: '...',
                          timestamp: DateTime.now(),
                        ),
                        isGenerating: true,
                      );
                    }
                    return ChatBubble(message: messages[index]);
                  },
                ),
        ),
        _buildMessageInput(theme),
      ],
    );
  }

  Widget _buildEmptyChat(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Börja konversationen',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Berätta om dina träningsmål, begränsningar och preferenser',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !_isGenerating,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Skriv ditt meddelande...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isGenerating ? null : _sendMessage,
              icon: _isGenerating
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.send),
              tooltip: 'Skicka',
            ),
          ],
        ),
      ),
    );
  }
}
