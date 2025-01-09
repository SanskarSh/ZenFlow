import 'package:carousel_slider/carousel_slider.dart';
import 'package:todo/src/core/common/ui_imports.dart';
import 'package:todo/src/core/constant/enumerates.dart';

class PriorityCarousel extends StatelessWidget {
  final Rx<Priority> priority;

  const PriorityCarousel({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: .2),
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
                Obx(
                  () => Text(
                    priority.value.toString().split('.').last,
                    style: TextStyle(
                      color: _getPriorityColor(priority.value),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
                                                .withValues(alpha: .4),
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
    );
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
