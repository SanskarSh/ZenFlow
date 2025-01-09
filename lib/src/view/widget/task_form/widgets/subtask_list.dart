import 'package:todo/src/core/common/ui_imports.dart';
import 'package:drift/drift.dart' as drift_data_class;

class SutTaskList extends StatelessWidget {
  const SutTaskList({super.key, required this.subTasks});

  final RxList<SubTasksCompanion> subTasks;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      spacing: 8,
      children: [
        Obx(
          () => subTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(
                        Icons.playlist_add,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      Text(
                        'No sub-tasks yet',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
              : Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: subTasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        color: theme.colorScheme.surface,
                        child: Dismissible(
                          key: Key(subTasks[index].title.toString()),
                          background: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.delete,
                              color: theme.colorScheme.onError,
                            ),
                          ),
                          onDismissed: (direction) {
                            subTasks.removeAt(index);
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              subTasks[index].title.value.toString(),
                              style: theme.textTheme.bodyLarge,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: theme.colorScheme.error,
                              ),
                              onPressed: () => subTasks.removeAt(index),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: _addSubTask,
            style: theme.elevatedButtonTheme.style?.copyWith(
              backgroundColor: WidgetStateProperty.all(
                theme.colorScheme.onPrimary,
              ),
              shape: WidgetStateProperty.all(
                CircleBorder(
                  side: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
              ),
            ),
            child: Icon(
              Icons.add,
              size: 24,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  void _addSubTask() async {
    final result = await Get.dialog<SubTasksCompanion>(AddSubTaskDialog());
    if (result != null) {
      subTasks.add(result);
    }
  }
}

// Add Sub Task Dialog with GetX
class AddSubTaskDialog extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final RxString title = ''.obs;

  AddSubTaskDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: theme.colorScheme.surface,
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            minHeight: 200,
            maxHeight: 250,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.playlist_add,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const Text(
                      'Add Sub-task',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Sub-task Title',
                      hintText: 'Enter sub-task description',
                      prefixIcon: const Icon(Icons.check_circle_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a title' : null,
                    onChanged: (value) => title.value = value,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: theme.elevatedButtonTheme.style,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Get.back(
                            result: SubTasksCompanion(
                              title: drift_data_class.Value(title.value),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
                      label: Text('Add', style: theme.textTheme.bodySmall),
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
