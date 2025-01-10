import 'package:todo/src/core/common/ui_imports.dart';
import 'package:todo/src/core/constant/enumerates.dart';
import 'package:todo/src/core/utils/date_utils.dart';
import 'package:todo/src/data/local_db/dao/task_dao.dart';
import 'package:drift/drift.dart' as drift_data_class;

// Form Widgets
import 'package:todo/src/view/widget/task_form/form_content_builder.dart';
import 'package:todo/src/view/widget/task_form/widgets/carry_forward.dart';
import 'package:todo/src/view/widget/task_form/widgets/description_text_field.dart';
import 'package:todo/src/view/widget/task_form/widgets/form_navigation_buttons.dart';
import 'package:todo/src/view/widget/task_form/widgets/info_tip_card.dart';
import 'package:todo/src/view/widget/task_form/widgets/priority_caraousal.dart';
import 'package:todo/src/view/widget/task_form/widgets/scheduled_date.dart';
import 'package:todo/src/view/widget/task_form/widgets/sub_task_tip_card.dart';
import 'package:todo/src/view/widget/task_form/widgets/subtask_list.dart';
import 'package:todo/src/view/widget/task_form/widgets/title_text_field.dart';
import 'package:todo/src/view/widget/task_form/widgets/week_days_selector.dart';

class TaskForm extends GetView<TaskController> {
  final FormType formType;
  final TaskWithSubTasks? edit;

  const TaskForm({super.key, required this.formType, this.edit});
  @override
  Widget build(BuildContext context) {
    if (formType == FormType.reminder) {
      return const ReminderFormContent();
    } else {
      if (formType == FormType.routine) {
        return TaskFormContent(isRoutine: true.obs, edit: edit);
      } else {
        return TaskFormContent(isRoutine: false.obs, edit: edit);
      }
    }
  }
}

class TaskFormContent extends StatelessWidget {
  final TaskWithSubTasks? edit;
  final RxBool isRoutine;

  late final TaskController controller;
  late final PageController pageController;
  late final GlobalKey<FormState> formKey;
  late final FocusNode titleFocusNode;
  late final FocusNode descriptionFocusNode;
  late final RxInt currentPage;
  final int totalPages = 3;

  // Move the observable variables to be late final
  late final RxString title;
  late final RxString description;
  late final Rx<DateTime> scheduledAt;
  late final Rx<Priority> priority;
  late final RxList<WeekDay> assignedWeekDays;
  late final RxBool isCarryForward;
  late final RxList<SubTasksCompanion> subTasks;

  TaskFormContent({super.key, required this.isRoutine, this.edit}) {
    // Initialize controllers and keys
    controller = Get.find<TaskController>();
    pageController = PageController();
    formKey = GlobalKey<FormState>();
    titleFocusNode = FocusNode();
    descriptionFocusNode = FocusNode();
    currentPage = 0.obs;

    // Initialize form data
    title = ''.obs;
    description = ''.obs;
    scheduledAt = DateTime.now().obs;
    priority = Priority.medium.obs;
    assignedWeekDays = <WeekDay>[].obs;
    isCarryForward = false.obs;
    subTasks = <SubTasksCompanion>[].obs;

    if (edit != null) {
      // Set basic information
      title.value = edit!.task.title;
      description.value = edit!.task.description ?? '';
      priority.value = edit!.task.priority;

      // Set schedule and settings
      if (edit!.task.isRoutine) {
        isRoutine.value = true;
        // Convert timeOfRoutineScheduled (minutes) to DateTime
        if (edit!.task.timeOfRoutineScheduled != null) {
          final hours = edit!.task.timeOfRoutineScheduled! ~/ 60;
          final minutes = edit!.task.timeOfRoutineScheduled! % 60;
          final now = DateTime.now();
          scheduledAt.value = DateTime(
            now.year,
            now.month,
            now.day,
            hours,
            minutes,
          );
        }
        // Set assigned week days
        if (edit!.task.assignedWeekDays != null) {
          assignedWeekDays.value = WeekDayConverter.decodeWeekDays(
            edit!.task.assignedWeekDays,
          )!;
        }
      } else {
        isRoutine.value = false;
        if (edit!.task.dateAndTimeOfTaskScheduled != null) {
          scheduledAt.value = edit!.task.dateAndTimeOfTaskScheduled!;
        }
        isCarryForward.value = edit!.task.isCarryForward;
      }

      // Set subtasks
      if (edit!.subTasks.isNotEmpty) {
        subTasks.value = edit!.subTasks
            .map((subtask) => SubTasksCompanion(
                  id: drift_data_class.Value(subtask.id!),
                  taskId: drift_data_class.Value(subtask.taskId),
                  title: drift_data_class.Value(subtask.title),
                  isCompleted: drift_data_class.Value(subtask.isCompleted),
                ))
            .toList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void submitForm() {
      if (!formKey.currentState!.validate()) {
        return;
      }

      if (isRoutine.value && assignedWeekDays.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select at least one week day for routine task',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (scheduledAt.value == DateTime.now() ||
          scheduledAt.value.isBefore(DateTime.now())) {
        Get.snackbar(
          'Error',
          'Please select a future date for ${isRoutine.value ? 'routine' : 'task'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final Future<void> action;
      if (edit != null) {
        // Create updated task
        final updatedTask = Task(
          id: edit!.task.id,
          title: title.value,
          description: description.value.isEmpty ? null : description.value,
          dateAndTimeOfTaskScheduled:
              isRoutine.value ? null : scheduledAt.value,
          timeOfRoutineScheduled: isRoutine.value
              ? scheduledAt.value.hour * 60 + scheduledAt.value.minute
              : null,
          priority: priority.value,
          isRoutine: isRoutine.value,
          assignedWeekDays: isRoutine.value
              ? WeekDayConverter.encodeWeekDays(assignedWeekDays)
              : null,
          isCarryForward: isCarryForward.value,
          isCompleted: edit!.task.isCompleted,
          createdAt: edit!.task.createdAt,
          editedAt: DateTime.now(),
        );

        final updatedSubTasks = subTasks.map((subtask) {
          if (subtask.id.present) {
            return SubTask(
              id: subtask.id.value,
              taskId: edit!.task.id,
              title: subtask.title.value,
              isCompleted: subtask.isCompleted.value,
              description: subtask.description.value,
            );
          } else {
            return SubTask(
              taskId: edit!.task.id,
              title: subtask.title.value,
              isCompleted: subtask.isCompleted.value,
              description: subtask.description.value,
            );
          }
        }).toList();

        final updatedTaskWithSubtasks = TaskWithSubTasks(
          task: updatedTask,
          subTasks: updatedSubTasks,
        );

        action = controller.updateTask(updatedTaskWithSubtasks);
      } else {
        // Create new task
        action = controller.createTask(
          title: title.value,
          description: description.value.isEmpty ? null : description.value,
          scheduledAt: scheduledAt.value,
          priority: priority.value,
          isRoutine: isRoutine.value,
          assignedWeekDays: isRoutine.value ? assignedWeekDays : null,
          isCarryForward: isCarryForward.value,
          subTasks: subTasks.isNotEmpty
              ? subTasks
                  .map((st) => SubTasksCompanion(
                        title: st.title,
                        isCompleted: const drift_data_class.Value(false),
                        description: const drift_data_class.Value(null),
                      ))
                  .toList()
              : null,
        );
      }

      action.then((_) {
        Get.back();
        Get.snackbar(
          'Success',
          edit != null
              ? 'Task updated successfully'
              : 'Task created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }).catchError((error) {
        Get.snackbar(
          'Error',
          error.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    }

    final theme = Theme.of(context);
    return SafeArea(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) => currentPage.value = page,
                children: [
                  FormContentBuilder(
                    title: 'Basic Information',
                    icon: Icons.info_outline,
                    content: _buildBasicInfoPage(context),
                  ),
                  FormContentBuilder(
                    title: 'Schedule & Settings',
                    icon: Icons.schedule,
                    content: _buildScheduleSettingsPage(isRoutine.value),
                  ),
                  FormContentBuilder(
                    title: 'Sub Tasks',
                    icon: Icons.checklist,
                    content: _buildSubTasksPage(),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: .1),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Obx(
                    () => LinearProgressIndicator(
                      value: (currentPage.value + 1) / totalPages,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  FormNavigationButtons(
                    currentPage: currentPage,
                    pageController: pageController,
                    totalPages: totalPages,
                    formKey: formKey,
                    submitForm: submitForm,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage(BuildContext context) {
    return Column(
      spacing: 24,
      children: [
        // Title Input Section
        TitleTextField(
          title: title,
          focusNode: titleFocusNode,
          onFieldSubmitted: (_) {
            formKey.currentState!.validate();
            FocusScope.of(context).requestFocus(descriptionFocusNode);
          },
        ),

        // Description Input Section
        DescriptionTextField(
          description: description,
          focusNode: descriptionFocusNode,
          onFieldSubmitted: (_) {
            descriptionFocusNode.unfocus();
          },
        ),

        // Tips Card
        const InfoTipCard(),
      ],
    );
  }

  Widget _buildScheduleSettingsPage(bool isRoutine) {
    return Column(
      spacing: 24,
      children: [
        // Priority Section
        PriorityCarousel(priority: priority),

        // Schedule Section
        ScheduledDate(scheduledAt: scheduledAt, isRoutine: isRoutine),

        // Task Settings Section
        if (!isRoutine) CarryForward(isCarryForward: isCarryForward),

        // Routine Days Section
        WeekDaysSelector(
          assignedWeekDays: assignedWeekDays,
          isRoutine: isRoutine.obs,
        )
      ],
    );
  }

  Widget _buildSubTasksPage() {
    return Column(
      spacing: 24,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub tasks tip
        const SubTaskTipCard(),

        // Sub Task List
        SutTaskList(subTasks: subTasks, edit: edit),
      ],
    );
  }
}

class ReminderFormContent extends StatelessWidget {
  const ReminderFormContent({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TaskController controller = Get.find<TaskController>();
    final RxString title = ''.obs;
    final RxString description = ''.obs;
    final Rx<DateTime> scheduledAt = DateTime.now().obs;

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final FocusNode titleFocusNode = FocusNode();
    final FocusNode descriptionFocusNode = FocusNode();

    void submitForm() {
      if (!formKey.currentState!.validate()) {
        return;
      }

      if (scheduledAt.value == DateTime.now() ||
          scheduledAt.value.isBefore(DateTime.now())) {
        Get.snackbar(
          'Error',
          'Please select a future date for reminder',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      controller
          .createReminder(
        title: title.value,
        description: description.value.isEmpty ? null : description.value,
        scheduledAt: scheduledAt.value,
      )
          .then((_) {
        Get.back();
        Get.snackbar('Success', 'Task created successfully',
            snackPosition: SnackPosition.BOTTOM);
      }).catchError((error) {
        Get.snackbar(
          'Error',
          error.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    }

    return SafeArea(
      child: Form(
        key: formKey,
        child: FormContentBuilder(
          title: 'Add Reminder',
          icon: Icons.info_outline,
          content: Column(
            spacing: 24,
            children: [
              // Tips Card
              // TODO Make it customisable
              const InfoTipCard(),

              // Title Input Section
              TitleTextField(
                title: title,
                focusNode: titleFocusNode,
                onFieldSubmitted: (_) {
                  formKey.currentState!.validate();
                  FocusScope.of(context).requestFocus(descriptionFocusNode);
                },
              ),

              // Description Input Section
              DescriptionTextField(
                description: description,
                focusNode: descriptionFocusNode,
                onFieldSubmitted: (_) {
                  descriptionFocusNode.unfocus();
                },
              ),

              // Schedule Section
              ScheduledDate(scheduledAt: scheduledAt, isRoutine: false),

              // Submit Button
              ElevatedButton.icon(
                style: theme.elevatedButtonTheme.style,
                icon: Icon(Icons.check, color: theme.colorScheme.onPrimary),
                label: Text('Submit', style: theme.textTheme.bodySmall),
                onPressed: submitForm,
              )
            ],
          ),
        ),
      ),
    );
  }
}
