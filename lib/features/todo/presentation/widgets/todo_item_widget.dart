import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/todo.dart';

class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
            color: todo.completed ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description != null && todo.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                todo.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: todo.completed ? Colors.grey[400] : Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(todo.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 4),
                if (!todo.synced)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Not synced',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
