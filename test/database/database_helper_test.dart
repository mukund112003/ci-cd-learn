import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:to_do/database/database_helper.dart';
import 'package:to_do/models/todo_model.dart';
import 'package:path/path.dart';

void main() {
  late DatabaseHelper dbHelper;

  setUpAll(() {
    // Initialize FFI for tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    // We clear the table before each test to ensure isolation
    final db = await dbHelper.database;
    await db.delete('todos');
  });

  tearDownAll(() async {
    // Close and delete db when all tests complete
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todos.db');
    await dbHelper.close();
    await databaseFactory.deleteDatabase(path);
  });

  group('DatabaseHelper CRUD Tests', () {
    test('should insert a todo and return it with id', () async {
      final todo = TodoModel(
        title: 'Test Todo',
        content: 'Test content',
        createdAt: DateTime.now(),
      );

      final inserted = await dbHelper.insertTodo(todo);

      expect(inserted.id, isNotNull);
      expect(inserted.title, 'Test Todo');
      expect(inserted.content, 'Test content');
    });

    test('should retrieve all inserted todos', () async {
      final todo1 = TodoModel(title: 'A', content: 'c1', createdAt: DateTime.now().subtract(const Duration(days: 1)));
      final todo2 = TodoModel(title: 'B', content: 'c2', createdAt: DateTime.now());

      await dbHelper.insertTodo(todo1);
      await dbHelper.insertTodo(todo2);

      final todos = await dbHelper.getTodos();

      // Ordered by createdAt DESC
      expect(todos.length, 2);
      expect(todos.first.title, 'B'); // newest first
      expect(todos[1].title, 'A');
    });

    test('should get a single todo by id', () async {
      final todo = TodoModel(
        title: 'Single',
        content: 'Retrieval',
        createdAt: DateTime.now(),
      );

      final inserted = await dbHelper.insertTodo(todo);
      expect(inserted.id, isNotNull);

      final retrieved = await dbHelper.getTodo(inserted.id!);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, inserted.id);
      expect(retrieved.title, 'Single');
      expect(retrieved.content, 'Retrieval');
    });

    test('should update a todo correctly', () async {
      final todo = TodoModel(
        title: 'Before Update',
        content: 'Content 1',
        createdAt: DateTime.now(),
      );

      final inserted = await dbHelper.insertTodo(todo);

      final updatedModel = inserted.copyWith(
        title: 'After Update',
        content: 'Content 2',
      );

      final updatedRows = await dbHelper.updateTodo(updatedModel);
      expect(updatedRows, 1);

      final retrieved = await dbHelper.getTodo(inserted.id!);
      expect(retrieved!.title, 'After Update');
      expect(retrieved.content, 'Content 2');
    });

    test('should delete a todo correctly', () async {
      final todo = TodoModel(
        title: 'To Delete',
        content: 'Will be removed',
        createdAt: DateTime.now(),
      );

      final inserted = await dbHelper.insertTodo(todo);

      final deletedRows = await dbHelper.deleteTodo(inserted.id!);
      expect(deletedRows, 1);

      final retrieved = await dbHelper.getTodo(inserted.id!);
      expect(retrieved, isNull);
    });
  });
}
