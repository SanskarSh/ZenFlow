import 'package:todo/src/core/common/ui_imports.dart';
import 'package:todo/src/data/local_db/dao/task_dao.dart';
import 'package:todo/src/view/widget/task_form/add_sub_task_dialog.dart';

class SutTaskList extends StatelessWidget {
  final TaskWithSubTasks? edit;
  final RxList<SubTasksCompanion> subTasks;

  const SutTaskList({super.key, required this.subTasks, this.edit});

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
    final result = await Get.dialog<SubTasksCompanion>(
        AddSubTaskDialog(taskId: edit?.task.id));
    if (result != null) {
      subTasks.add(result);
    }
  }
}
