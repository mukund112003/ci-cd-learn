import 'package:flutter_test/flutter_test.dart';
import 'package:to_do/models/todo_model.dart';

void main() {
  group('TodoModel Tests', () {
    final DateTime now = DateTime.now();

    test('should construct correctly', () {
      final todo = TodoModel(
        id: 1,
        title: 'Test Title',
        content: 'Test Content',
        createdAt: now,
      );

      expect(todo.id, 1);
      expect(todo.title, 'Test Title');
      expect(todo.content, 'Test Content');
      expect(todo.createdAt, now);
    });

    test('should correctly convert to Map', () {
      final todo = TodoModel(
        id: 1,
        title: 'Test Title',
        content: 'Test Content',
        createdAt: now,
      );

      final map = todo.toMap();
      expect(map['id'], 1);
      expect(map['title'], 'Test Title');
      expect(map['content'], 'Test Content');
      expect(map['createdAt'], now.toIso8601String());
    });

    test('should correctly create from Map', () {
      final map = {
        'id': 2,
        'title': 'Map Title',
        'content': 'Map Content',
        'createdAt': now.toIso8601String(),
      };

      final todo = TodoModel.fromMap(map);
      expect(todo.id, 2);
      expect(todo.title, 'Map Title');
      expect(todo.content, 'Map Content');
      expect(todo.createdAt, now);
    });

    test('should correctly copyWith properties', () {
      final todo = TodoModel(
        id: 1,
        title: 'Old Title',
        content: 'Old Content',
        createdAt: now,
      );

      final updated = todo.copyWith(title: 'New Title', content: 'New Content');

      expect(updated.id, 1);
      expect(updated.title, 'New Title');
      expect(updated.content, 'New Content');
      expect(updated.createdAt, now);
    });

    test('should not change properties if copyWith arguments are null', () {
      final todo = TodoModel(
        id: 1,
        title: 'Old Title',
        content: 'Old Content',
        createdAt: now,
      );

      final updated = todo.copyWith();

      expect(updated.id, todo.id);
      expect(updated.title, todo.title);
      expect(updated.content, todo.content);
      expect(updated.createdAt, todo.createdAt);
    });
  });
}
