import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_controller.dart';
import '../providers/todo_providers.dart';
import '../widgets/todo_item_widget.dart';
import '../widgets/add_todo_dialog.dart';

class TodoListPage extends ConsumerWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoControllerProvider);
    final networkStatus = ref.watch(networkStatusProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO App'),
        actions: [
          networkStatus.when(
            data: (isConnected) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                isConnected ? Icons.wifi : Icons.wifi_off,
                color: isConnected ? Colors.green : Colors.red,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          syncStatus.when(
            data: (isSyncing) => isSyncing
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Manual sync button
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              ref.read(todoControllerProvider.notifier).syncTodos();
            },
          ),
        ],
      ),
      body: todosAsync.when(
        data: (todos) {
          if (todos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No todos yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a todo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(todoControllerProvider.notifier).loadTodos();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return TodoItemWidget(
                  todo: todo,
                  onToggle: () {
                    ref
                        .read(todoControllerProvider.notifier)
                        .toggleTodoComplete(todo);
                  },
                  onDelete: () {
                    ref
                        .read(todoControllerProvider.notifier)
                        .deleteTodo(todo.id);
                  },
                  onEdit: () {
                    _showEditTodoDialog(context, ref, todo);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(todoControllerProvider.notifier).loadTodos();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddTodoDialog(
        onAdd: (title, description) {
          ref.read(todoControllerProvider.notifier).addTodo(
                title: title,
                description: description,
              );
        },
      ),
    );
  }

  void _showEditTodoDialog(BuildContext context, WidgetRef ref, todo) {
    showDialog(
      context: context,
      builder: (context) => AddTodoDialog(
        initialTitle: todo.title,
        initialDescription: todo.description,
        isEdit: true,
        onAdd: (title, description) {
          final updatedTodo = todo.copyWith(
            title: title,
            description: description.isEmpty ? null : description,
          );
          ref.read(todoControllerProvider.notifier).updateTodo(updatedTodo);
        },
      ),
    );
  }
}
