import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:todo/src/controller/task_controller.dart';
import 'package:todo/src/controller/theme_controller.dart';
import 'package:todo/src/view/widget/task_form.dart';
import 'package:todo/src/view/widget/task_tile_widget.dart';
import 'package:todo/src/view/widget/theme_toggle_btn.dart';

class TodoMobile extends GetView<TaskController> {
  const TodoMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsController = Get.find<SettingsController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('My Tasks'),
          actions: [
            ToggleTheme(controller: settingsController),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Tasks',
                icon: Icon(Icons.task, color: theme.colorScheme.primary),
              ),
              Tab(
                text: 'Routines',
                icon: Icon(Icons.repeat, color: theme.colorScheme.secondary),
              ),
              Tab(
                text: 'Completed',
                icon: Icon(Icons.done_all, color: theme.colorScheme.tertiary),
              ),
            ],
            labelColor: theme.colorScheme.onSurface,
            unselectedLabelColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorColor: theme.colorScheme.primary,
          ),
        ),
        body: Obx(
          () => TabBarView(
            children: [
              _buildTaskList(controller.tasks, context),
              _buildTaskList(controller.routineTasks, context),
              _buildTaskList(controller.completedTasks, context),
            ],
          ),
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: _buildExpandableFab(context),
      ),
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListWidget(task: task);
            },
          );
  }

  Widget _buildExpandableFab(BuildContext context) {
    final theme = Theme.of(context);

    if (!Get.isRegistered<GlobalKey<ExpandableFabState>>()) {
      Get.put(GlobalKey<ExpandableFabState>());
    }
    final fabKey = Get.find<GlobalKey<ExpandableFabState>>();

    return ExpandableFab(
      key: fabKey,
      type: ExpandableFabType.fan,
      pos: ExpandableFabPos.right,
      overlayStyle: ExpandableFabOverlayStyle(
        blur: 2,
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
      ),
      childrenAnimation: ExpandableFabAnimation.rotate,
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.add),
        fabSize: ExpandableFabSize.regular,
        foregroundColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.primary,
        shape: const CircleBorder(),
      ),
      closeButtonBuilder: DefaultFloatingActionButtonBuilder(
        child: const Icon(Icons.close),
        fabSize: ExpandableFabSize.small,
        foregroundColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.onPrimary,
        shape: const CircleBorder(),
      ),
      children: [
        _buildFabChild(
          context: context,
          icon: FontAwesome.list_check_solid,
          tooltip: "Add Task",
          color: theme.colorScheme.primary,
          onPressed: () =>
              _showAddTaskDialog(false, theme.colorScheme.primary, context),
        ),
        _buildFabChild(
          context: context,
          icon: EvaIcons.calendar_outline,
          tooltip: "Add Routine",
          color: theme.colorScheme.secondary,
          onPressed: () =>
              _showAddTaskDialog(true, theme.colorScheme.secondary, context),
        ),
        _buildFabChild(
          context: context,
          icon: EvaIcons.bell_outline,
          tooltip: "Add Reminder",
          color: theme.colorScheme.tertiary,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildFabChild({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      padding: const EdgeInsets.all(10),
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(color),
        elevation: WidgetStateProperty.all(4),
      ),
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }

  void _showAddTaskDialog(bool isRoutine, Color color, BuildContext context) {
    final key = Get.find<GlobalKey<ExpandableFabState>>();
    key.currentState?.toggle();

    Get.dialog(
      Dialog(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AddTaskForm(color, isRoutine: isRoutine.obs),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    ).then((_) {
      if (key.currentState?.isOpen ?? false) {
        key.currentState?.toggle();
      }
    });
  }
}
