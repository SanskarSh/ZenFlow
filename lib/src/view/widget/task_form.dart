import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/src/controller/task_controller.dart';
import 'package:todo/src/core/constant/enumerates.dart';
import 'package:todo/src/data/db/drift_db.dart';
import 'package:drift/drift.dart' as drift_data_class;
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AddTaskForm extends GetView<TaskController> {
  final RxBool isRoutine;
  final Color bgColor;
  const AddTaskForm(this.bgColor, {super.key, required this.isRoutine});
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
  _TaskFormContentState createState() => _TaskFormContentState();
}

class _TaskFormContentState extends State<TaskFormContent> {
  final TaskController controller = Get.find<TaskController>();
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => Get.back(),
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (int page) => _currentPage.value = page,
                        children: [
                          _buildPage(
                            title: 'Basic Information',
                            icon: Icons.info_outline,
                            content: _buildBasicInfoPage(),
                          ),
                          _buildPage(
                            title: 'Schedule & Settings',
                            icon: Icons.schedule,
                            content: _buildScheduleSettingsPage(),
                          ),
                          _buildPage(
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
                            color: theme.colorScheme.outline.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(() => LinearProgressIndicator(
                                value: (_currentPage.value + 1) / _totalPages,
                                backgroundColor:
                                    theme.colorScheme.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              )),
                          const SizedBox(height: 16),
                          _buildNavigationButtons(),
                        ],
                      ),
                    ),
                    // Obx(() => LinearProgressIndicator(
                    //       value: (_currentPage.value + 1) / _totalPages,
                    //       backgroundColor:
                    //           theme.colorScheme.surfaceContainerHighest,
                    //       valueColor: AlwaysStoppedAnimation<Color>(
                    //         theme.colorScheme.primary,
                    //       ),
                    //     )),
                    // _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSettingsPage() {
    final theme = Theme.of(context);
    return Column(
      spacing: 24,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Priority Section
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              spacing: 24,
              children: [
                Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(() => Text(
                          priority.value.toString().split('.').last,
                          style: TextStyle(
                            color: _getPriorityColor(priority.value),
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                  ],
                ),
                const Spacer(),
                Expanded(
                  child: SizedBox(
                    height: 120,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        scrollDirection: Axis.vertical,
                        height: 120,
                        viewportFraction: 0.3,
                        enlargeCenterPage: true,
                        initialPage: Priority.values.indexOf(priority.value),
                        onPageChanged: (index, reason) {
                          priority.value = Priority.values[index];
                        },
                      ),
                      items: Priority.values.map(
                        (Priority value) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Obx(
                                () => Center(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: priority.value == value ? 24 : 16,
                                    height: priority.value == value ? 24 : 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _getPriorityColor(value),
                                      boxShadow: priority.value == value
                                          ? [
                                              BoxShadow(
                                                color: _getPriorityColor(value)
                                                    .withOpacity(0.4),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Schedule Section
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: () => _selectDateTime(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 12,
                    children: [
                      Icon(
                        Icons.event,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              spacing: 8,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        DateFormat('MMM d')
                                            .format(scheduledAt.value),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('EEEE')
                                          .format(scheduledAt.value),
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 4,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    Text(
                                      DateFormat('h:mm a')
                                          .format(scheduledAt.value),
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.edit_calendar,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to change date and time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Task Settings Section
        Obx(
          () => GestureDetector(
            onTap: () => isCarryForward.value = !isCarryForward.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isCarryForward.value
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCarryForward.value ? 'Enabled' : 'Disabled',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isCarryForward.value
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Incomplete tasks carry forward to the next day',
                          style: TextStyle(
                            fontSize: 12,
                            color: isCarryForward.value
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.8)
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCarryForward.value
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceVariant,
                      border: Border.all(
                        color: isCarryForward.value
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isCarryForward.value ? Icons.check : Icons.close,
                        key: ValueKey<bool>(isCarryForward.value),
                        color: isCarryForward.value
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Routine Days Section
        Obx(
          () {
            if (widget.isRoutine.value) {
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                color: theme.colorScheme.surface,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    spacing: 12,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Repeat on:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 1.0,
                        children: WeekDay.values.map((WeekDay day) {
                          return FilterChip(
                            selected: assignedWeekDays.contains(day),
                            label: Text(day
                                .toString()
                                .split('.')
                                .last[0]
                                .toUpperCase()),
                            onSelected: (bool selected) => _toggleWeekDay(day),
                            selectedColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }

  Widget _buildPage({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Icon(
                      icon,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: content,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoPage() {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Title Input Section
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'What would you like to do?',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.task_alt,
                color: theme.colorScheme.primary,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a task title';
              }
              return null;
            },
            onChanged: (value) => title.value = value,
          ),
        ),
        const SizedBox(height: 24),

        // Description Input Section
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.notes_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Additional Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                style: const TextStyle(
                  fontSize: 16,
                ),
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Add notes, subtasks, or any relevant details...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  counter: const SizedBox.shrink(),
                ),
                onChanged: (value) => description.value = value,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tips Card
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Show more detailed tips if needed
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: .8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.tips_and_updates_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Writing effective tasks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Be specific and actionable with your task description',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTasksPage() {
    final theme = Theme.of(context);
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              spacing: 12,
              children: [
                Icon(
                  Icons.checklist_rtl,
                  color: theme.colorScheme.primary,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Break down your task',
                        style: theme.textTheme.titleMedium,
                      ),
                      FittedBox(
                        child: Text(
                          'Add smaller, manageable sub-tasks',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
                      // ElevatedButton.icon(
                      //   onPressed: _addSubTask,
                      //   icon: Icon(
                      //     Icons.add,
                      //     color: theme.colorScheme.onPrimary,
                      //   ),
                      //   label: Text(
                      //     'Add Sub-task',
                      //     style: theme.textTheme.bodySmall,
                      //   ),
                      // ),
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
                            color: theme.colorScheme.outline.withOpacity(0.2),
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

  Widget _buildNavigationButtons() {
    final theme = Theme.of(context);
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (_currentPage.value > 0)
              ElevatedButton.icon(
                style: theme.elevatedButtonTheme.style,
                onPressed: () {
                  _pageController.previousPage(
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
            if (_currentPage.value < _totalPages - 1)
              ElevatedButton.icon(
                style: theme.elevatedButtonTheme.style,
                onPressed: () {
                  if (_currentPage.value == 0 &&
                      !_formKey.currentState!.validate()) {
                    return;
                  }
                  _pageController.nextPage(
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
            if (_currentPage.value == _totalPages - 1)
              ElevatedButton.icon(
                style: theme.elevatedButtonTheme.style,
                icon: Icon(Icons.check, color: theme.colorScheme.onPrimary),
                label: Text('Submit', style: theme.textTheme.bodySmall),
                onPressed: () => _submitForm(),
              )
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: scheduledAt.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(scheduledAt.value),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Theme.of(context).colorScheme.surface,
                hourMinuteShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                dayPeriodShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        scheduledAt.value = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
      }
    }
  }

  void _addSubTask() async {
    final result = await Get.dialog<SubTasksCompanion>(AddSubTaskDialog());
    if (result != null) {
      subTasks.add(result);
    }
  }

  void _toggleWeekDay(WeekDay weekDay) {
    if (assignedWeekDays.contains(weekDay)) {
      assignedWeekDays.remove(weekDay);
    } else {
      assignedWeekDays.add(weekDay);
    }
  }

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

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return const Color(0xFF4CAF50); // Green
      case Priority.medium:
        return const Color(0xFFFFA726); // Orange
      case Priority.high:
        return const Color(0xFFEF5350); // Red
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
