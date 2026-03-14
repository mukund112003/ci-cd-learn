import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class TodoCard extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'MMM dd, yyyy • HH:mm',
    ).format(todo.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade300,
                  Colors.deepPurple.shade400,
                  Colors.indigo.shade500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        todo.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white70,
                      ),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
                if (todo.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    todo.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
