class TodoModel {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;

  TodoModel({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  // Convert TodoModel to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create TodoModel from Map (database)
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Create a copy with updated fields
  TodoModel copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
