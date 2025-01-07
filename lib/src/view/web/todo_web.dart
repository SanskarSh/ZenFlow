import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:todo/src/controller/task_controller.dart';
import 'package:todo/src/controller/theme_controller.dart';
import 'package:todo/src/view/widget/task_form.dart';
import 'package:todo/src/view/widget/task_tile_widget.dart';
import 'package:todo/src/view/widget/theme_toggle_btn.dart';

class TodoWeb extends GetView<TaskController> {
  const TodoWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsController = Get.find<SettingsController>();
    final RxInt selectedIndex = 0.obs;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Row(
        children: [
          // Sidebar
          Card(
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: SizedBox(
              width: 280,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Tasks',
                          style: theme.textTheme.titleLarge,
                        ),
                        ToggleTheme(controller: settingsController),
                      ],
                    ),
                  ),
                  const Divider(),
                  Obx(() => _buildNavItem(
                        selectedIndex: selectedIndex.value,
                        index: 0,
                        icon: Icons.task,
                        title: 'Tasks',
                        color: theme.colorScheme.primary,
                        onTap: () => selectedIndex.value = 0,
                      )),
                  Obx(() => _buildNavItem(
                        selectedIndex: selectedIndex.value,
                        index: 1,
                        icon: Icons.repeat,
                        title: 'Routines',
                        color: theme.colorScheme.secondary,
                        onTap: () => selectedIndex.value = 1,
                      )),
                  Obx(() => _buildNavItem(
                        selectedIndex: selectedIndex.value,
                        index: 2,
                        icon: Icons.done_all,
                        title: 'Completed',
                        color: theme.colorScheme.tertiary,
                        onTap: () => selectedIndex.value = 2,
                      )),
                ],
              ),
            ),
          ),
          // Main content
          Expanded(
            child: Obx(() {
              switch (selectedIndex.value) {
                case 0:
                  return _buildTaskList(controller.tasks, context);
                case 1:
                  return _buildTaskList(controller.routineTasks, context);
                case 2:
                  return _buildTaskList(controller.completedTasks, context);
                default:
                  return _buildTaskList(controller.tasks, context);
              }
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showAddTaskDialog(false, theme.colorScheme.primary, context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildNavItem({
    required int selectedIndex,
    required int index,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(icon, color: isSelected ? color : null),
      title: Text(title),
      selected: isSelected,
      selectedColor: color,
      onTap: onTap,
    );
  }

  Widget _buildTaskList(tasks, BuildContext context) {
    final theme = Theme.of(context);

    return tasks.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt,
                  size: 64,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No tasks yet',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListWidget(task: task);
            },
          );
  }

  void _showAddTaskDialog(bool isRoutine, Color color, BuildContext context) {
    Get.dialog(
      Dialog(
        child: SizedBox(
          width: 400,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: AddTaskForm(color, isRoutine: isRoutine.obs),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }
}
