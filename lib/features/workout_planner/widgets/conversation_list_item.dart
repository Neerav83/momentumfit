import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/workout_conversation.dart';

class ConversationListItem extends StatelessWidget {
  const ConversationListItem({
    required this.conversation,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final WorkoutConversation conversation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final conversationDate = DateTime(
      conversation.updatedAt.year,
      conversation.updatedAt.month,
      conversation.updatedAt.day,
    );
    
    final String dateText;
    if (conversationDate == today) {
      dateText = DateFormat.Hm().format(conversation.updatedAt);
    } else if (conversationDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Igår';
    } else if (now.difference(conversationDate).inDays < 7) {
      dateText = DateFormat.E('sv').format(conversation.updatedAt);
    } else {
      dateText = DateFormat.MMMd('sv').format(conversation.updatedAt);
    }

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                tooltip: 'Ta bort',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
