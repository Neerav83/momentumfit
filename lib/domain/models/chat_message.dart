enum MessageRole {
  user,
  assistant,
  system,
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.name == map['role'] as String,
      ),
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
