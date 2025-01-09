import 'package:todo/src/core/common/ui_imports.dart';
import 'package:todo/src/core/constant/enumerates.dart';

class WeekDaysSelector extends StatelessWidget {
  final RxList<WeekDay> assignedWeekDays;
  final RxBool isRoutine;
  const WeekDaysSelector(
      {super.key, required this.assignedWeekDays, required this.isRoutine});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Obx(
      () {
        if (isRoutine.value) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 1.0,
                    children: WeekDay.values.map((WeekDay day) {
                      return FilterChip(
                        selected: assignedWeekDays.contains(day),
                        label: Text(
                            day.toString().split('.').last[0].toUpperCase()),
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
    );
  }

  void _toggleWeekDay(WeekDay weekDay) {
    if (assignedWeekDays.contains(weekDay)) {
      assignedWeekDays.remove(weekDay);
    } else {
      assignedWeekDays.add(weekDay);
    }
  }
}
