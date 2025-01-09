import 'package:todo/src/core/common/ui_imports.dart';
import 'package:todo/src/core/constant/enumerates.dart';

// Form Widgets
import 'package:todo/src/view/widget/task_form/form_content_builder.dart';
import 'package:todo/src/view/widget/task_form/widgets/carry_forward.dart';
import 'package:todo/src/view/widget/task_form/widgets/description_text_field.dart';
import 'package:todo/src/view/widget/task_form/widgets/info_tip_card.dart';
import 'package:todo/src/view/widget/task_form/widgets/priority_caraousal.dart';
import 'package:todo/src/view/widget/task_form/widgets/scheduled_date.dart';
import 'package:todo/src/view/widget/task_form/widgets/sub_task_tip_card.dart';
import 'package:todo/src/view/widget/task_form/widgets/subtask_list.dart';
import 'package:todo/src/view/widget/task_form/widgets/title_text_field.dart';
import 'package:todo/src/view/widget/task_form/widgets/week_days_selector.dart';

class TaskForm extends GetView<TaskController> {
  final RxBool isRoutine;
  final Color bgColor;
  const TaskForm(this.bgColor, {super.key, required this.isRoutine});
  @override
  Widget build(BuildContext context) {
    return TaskFormContent(
      isRoutine: isRoutine,
      bgColor: bgColor,
    );
  }
}

class TaskFormContent extends StatefulWidget {
  final RxBool isRoutine;
  final Color bgColor;

  const TaskFormContent(
      {super.key, required this.isRoutine, required this.bgColor});
  @override
  TaskFormContentState createState() => TaskFormContentState();
}

class TaskFormContentState extends State<TaskFormContent> {
  final TaskController controller = Get.find<TaskController>();
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RxInt _currentPage = 0.obs;
  final int _totalPages = 3;

  // Form data using GetX observables
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  final Rx<DateTime> scheduledAt = DateTime.now().obs;
  final Rx<Priority> priority = Priority.medium.obs;
  // final Rx<WeekDay> assignedWeekDay =
  //     WeekDay.values[DateTime.now().weekday % 7].obs;
  final RxList<WeekDay> assignedWeekDays = <WeekDay>[].obs;
  final RxBool isCarryForward = false.obs;
  final RxList<SubTasksCompanion> subTasks = <SubTasksCompanion>[].obs;

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.isRoutine.value && assignedWeekDays.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one week day for routine task',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    controller
        .createTask(
      title: title.value,
      description: description.value.isEmpty ? null : description.value,
      scheduledAt: scheduledAt.value,
      priority: priority.value,
      isRoutine: widget.isRoutine.value,
      assignedWeekDays: widget.isRoutine.value ? assignedWeekDays : null,
      isCarryForward: isCarryForward.value,
      subTasks: subTasks.isNotEmpty ? subTasks : null,
    )
        .then((_) {
      Get.back();
      Get.snackbar(
        'Success',
        'Task created successfully',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) => _currentPage.value = page,
                  children: [
                    FormContentBuilder(
                      title: 'Basic Information',
                      icon: Icons.info_outline,
                      content: _buildBasicInfoPage(),
                    ),
                    FormContentBuilder(
                      title: 'Schedule & Settings',
                      icon: Icons.schedule,
                      content: _buildScheduleSettingsPage(),
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
                        value: (_currentPage.value + 1) / _totalPages,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    FormNavigationButtons(
                      currentPage: _currentPage,
                      pageController: _pageController,
                      totalPages: _totalPages,
                      formKey: _formKey,
                      submitForm: _submitForm,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return Column(
      spacing: 24,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title Input Section
        TitleTextField(title: title),

        // Description Input Section
        DescriptionTextField(description: description),

        // Tips Card
        const InfoTipCard(),
      ],
    );
  }

  Widget _buildScheduleSettingsPage() {
    return Column(
      spacing: 24,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Priority Section
        PriorityCarousel(priority: priority),

        // Schedule Section
        ScheduledDate(scheduledAt: scheduledAt),

        // Task Settings Section
        CarryForward(isCarryForward: isCarryForward, context: context),

        // Routine Days Section
        WeekDaysSelector(
            assignedWeekDays: assignedWeekDays, isRoutine: widget.isRoutine)
      ],
    );
  }

  Widget _buildSubTasksPage() {
    final theme = Theme.of(context);
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub tasks tip
        SubTaskTipCard(theme: theme),

        // Sub Task List
        SutTaskList(subTasks: subTasks),
      ],
    );
  }
}

class FormNavigationButtons extends StatelessWidget {
  const FormNavigationButtons({
    super.key,
    required this.currentPage,
    required this.pageController,
    required this.totalPages,
    required this.formKey,
    required this.submitForm,
  });

  final RxInt currentPage;
  final PageController pageController;
  final int totalPages;
  final GlobalKey<FormState> formKey;
  final VoidCallback submitForm;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (currentPage.value > 0)
              ElevatedButton.icon(
                style: theme.elevatedButtonTheme.style,
                onPressed: () {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onPrimary,
                ),
                label: Text('Previous', style: theme.textTheme.bodySmall),
              ),
            if (currentPage.value < totalPages - 1)
              ElevatedButton.icon(
                style: theme.elevatedButtonTheme.style,
                onPressed: () {
                  if (currentPage.value == 0 &&
                      !formKey!.currentState!.validate()) {
                    return;
                  }
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(
                  Icons.arrow_forward,
                  color: theme.colorScheme.onPrimary,
                ),
                label: Text('Next', style: theme.textTheme.bodySmall),
              ),
            if (currentPage.value == totalPages - 1)
              ElevatedButton.icon(
                style: theme.elevatedButtonTheme.style,
                icon: Icon(Icons.check, color: theme.colorScheme.onPrimary),
                label: Text('Submit', style: theme.textTheme.bodySmall),
                onPressed: () => submitForm,
              )
          ],
        ),
      ),
    );
  }
}
