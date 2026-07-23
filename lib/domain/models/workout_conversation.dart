class WorkoutConversation {
  WorkoutConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  factory WorkoutConversation.fromMap(Map<String, dynamic> map) {
    return WorkoutConversation(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isArchived: (map['is_archived'] as int?) == 1,
    );
  }

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_archived': isArchived ? 1 : 0,
    };
  }

  WorkoutConversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return WorkoutConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
