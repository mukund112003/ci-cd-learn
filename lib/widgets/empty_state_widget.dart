import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 120,
            color: Colors.purple.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No To-Dos Yet!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade300,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the + button to create your first to-do',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
