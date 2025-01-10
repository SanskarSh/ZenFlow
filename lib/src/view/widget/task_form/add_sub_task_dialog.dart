import 'package:todo/src/core/common/ui_imports.dart';
import 'package:drift/drift.dart' as drift_data_class;

// Add Sub Task Dialog with GetX
class AddSubTaskDialog extends StatelessWidget {
  final String? taskId;
  final _formKey = GlobalKey<FormState>();
  final RxString title = ''.obs;
  final RxString description = ''.obs;

  AddSubTaskDialog({super.key, this.taskId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Dialog(
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
              maxHeight: 320,
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
                    child: Column(
                      spacing: 8,
                      children: [
                        TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            hintText: 'Enter sub-task title',
                            prefixIcon: const Icon(Icons.check_circle_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          onFieldSubmitted: (value) {
                            if (_formKey.currentState!.validate()) {
                              Get.back(
                                result: SubTasksCompanion(
                                  taskId: drift_data_class.Value(
                                    taskId ?? '',
                                  ),
                                  title: drift_data_class.Value(title.value),
                                  isCompleted:
                                      const drift_data_class.Value(false),
                                  description:
                                      const drift_data_class.Value(null),
                                ),
                              );
                            }
                          },
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Please enter a title'
                              : null,
                          onChanged: (value) => title.value = value,
                        ),
                        TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter details sub-task',
                            prefixIcon: const Icon(Icons.check_circle_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          onFieldSubmitted: (value) {
                            if (_formKey.currentState!.validate()) {
                              Get.back(
                                result: SubTasksCompanion(
                                  taskId: drift_data_class.Value(taskId ?? ''),
                                  title: drift_data_class.Value(title.value),
                                  description:
                                      drift_data_class.Value(description.value),
                                  isCompleted:
                                      const drift_data_class.Value(false),
                                ),
                              );
                            }
                          },
                          // validator: (value) => value?.isEmpty ?? true
                          //     ? 'Please enter a description'
                          //     : null,
                          onChanged: (value) => description.value = value,
                        ),
                      ],
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
                                taskId: drift_data_class.Value(taskId ?? ''),
                                title: drift_data_class.Value(title.value),
                                description:
                                    drift_data_class.Value(description.value),
                                isCompleted:
                                    const drift_data_class.Value(false),
                              ),
                            );
                          }
                        },
                        icon:
                            Icon(Icons.add, color: theme.colorScheme.onPrimary),
                        label: Text('Add', style: theme.textTheme.bodySmall),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
