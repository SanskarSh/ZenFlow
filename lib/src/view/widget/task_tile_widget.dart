import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/src/controller/task_controller.dart';
import 'package:todo/src/data/db/drift_db.dart';
import 'package:todo/src/view/widget/task_form.dart';

class ListWidget extends GetView<TaskController> {
  final dynamic task;
  const ListWidget({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    final isExpanded = false.obs;
    final hasSubtasks = task.subTasks.isNotEmpty;

    return Obx(() => Card(
          // color: task.task.priority == Priority.high
          //     ? theme.colorScheme.secondary.withValues(alpha:0.7)
          //     : task.task.priority == Priority.medium
          //         ? theme.colorScheme.tertiary.withValues(alpha:0.7)
          //         : task.task.priority == Priority.low
          //             ? theme.colorScheme.primary.withValues(alpha:0.7)
          //             : theme.colorScheme.surface,
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: task.task.isCompleted,
                            onChanged: (value) =>
                                controller.toggleTaskCompleted(
                                    task.task.id, value ?? false),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.task.title,
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        decoration: task.task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: task.task.isCompleted
                                            ? theme.colorScheme.onSurface
                                                .withValues(alpha: 0.6)
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  // Add expand/collapse button

                                  if (hasSubtasks) ...[
                                    IconButton(
                                      icon: AnimatedRotation(
                                        turns: isExpanded.value ? 0.5 : 0,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      onPressed: () => isExpanded.toggle(),
                                    ),
                                  ],
                                ],
                              ),
                              if (task.task.description != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  task.task.description!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat.format(task.task.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.add_task,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () =>
                                  _showAddSubtaskDialog(context, task),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () => onEdit(context, task),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: theme.colorScheme.error,
                              ),
                              onPressed: () => onDelete(context, task.task.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (task.task.isRoutine) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.repeat,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Routine Task',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Expandable subtasks section
              if (isExpanded.value) ...[
                const Divider(height: 1),
                _buildSubtasksList(context, task),
              ],
            ],
          ),
        ));
  }

  Widget _buildSubtasksList(BuildContext context, dynamic task) {
    final theme = Theme.of(context);

    final List<SubTask> subtasks = task.subTasks;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: subtasks.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No subtasks yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subtasks.length,
              itemBuilder: (context, index) {
                final subtask = subtasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: subtask.isCompleted,
                    onChanged: (value) {
                      controller.toggleSubTaskCompleted(
                        subtask.taskId,
                        subtask.id,
                        value ?? false,
                      );
                    },
                  ),
                  title: Text(
                    subtask.title,
                    style: TextStyle(
                      decoration: subtask.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () {
                      controller.deleteSubTask(task.task.id, subtask.id);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showAddSubtaskDialog(BuildContext context, dynamic task) {
    // final theme = Theme.of(context);
    final subtaskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: subtaskController,
          decoration: const InputDecoration(
            hintText: 'Enter subtask',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (subtaskController.text.isNotEmpty) {
                // TODO: Add subtask
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // TODO: Implement onEdit
  void onEdit(dynamic task, BuildContext context) {
    final theme = Theme.of(context);
    final color = task.task.isRoutine
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;

    Get.dialog(
      Dialog(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AddTaskForm(
            color,
            isRoutine: task.task.isRoutine.obs,
            // editTask: task,
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  void onDelete(BuildContext context, String taskId) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Delete Task',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            'Are you sure you want to delete this task?',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                controller.deleteTask(taskId);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
