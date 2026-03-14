import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../database/database_helper.dart';
import '../widgets/todo_card.dart';
import '../widgets/empty_state_widget.dart';
import 'add_edit_todo_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoModel> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    final todos = await DatabaseHelper.instance.getTodos();
    setState(() {
      _todos = todos;
      _isLoading = false;
    });
  }

  Future<void> _navigateToAddEdit({TodoModel? todo}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditTodoScreen(todo: todo)),
    );

    if (result == true) {
      _loadTodos();
    }
  }

  Future<void> _deleteTodo(TodoModel todo) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete To-Do'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await DatabaseHelper.instance.deleteTodo(todo.id!);
      _loadTodos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${todo.title}" deleted'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My To-Dos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade400,
                Colors.deepPurple.shade500,
                Colors.indigo.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_todos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_todos.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade50,
              Colors.deepPurple.shade50,
              Colors.indigo.shade50,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _todos.isEmpty
            ? const EmptyStateWidget()
            : RefreshIndicator(
                onRefresh: _loadTodos,
                color: Colors.purple.shade400,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _todos.length,
                  itemBuilder: (context, index) {
                    final todo = _todos[index];
                    return TodoCard(
                      todo: todo,
                      onTap: () => _navigateToAddEdit(todo: todo),
                      onDelete: () => _deleteTodo(todo),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(),
        backgroundColor: Colors.purple.shade400,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add To-Do',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
