import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(path, version: 1, onCreate: _createDB);
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE todos (
        id $idType,
        title $textType,
        content $textType,
        createdAt $textType
      )
    ''');
  }

  // Create - Insert a new todo
  Future<TodoModel> insertTodo(TodoModel todo) async {
    final db = await instance.database;
    final id = await db.insert('todos', todo.toMap());
    return todo.copyWith(id: id);
  }

  // Read - Get all todos
  Future<List<TodoModel>> getTodos() async {
    final db = await instance.database;
    const orderBy = 'createdAt DESC';

    final result = await db.query('todos', orderBy: orderBy);
    return result.map((json) => TodoModel.fromMap(json)).toList();
  }

  // Read - Get a single todo by id
  Future<TodoModel?> getTodo(int id) async {
    final db = await instance.database;

    final maps = await db.query('todos', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return TodoModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Update - Update an existing todo
  Future<int> updateTodo(TodoModel todo) async {
    final db = await instance.database;

    return db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Delete - Delete a todo
  Future<int> deleteTodo(int id) async {
    final db = await instance.database;

    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
