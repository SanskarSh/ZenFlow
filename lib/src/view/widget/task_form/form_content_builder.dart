import 'package:todo/src/core/common/ui_imports.dart';

class FormContentBuilder extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;
  const FormContentBuilder({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 24, color: theme.colorScheme.primary),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                iconSize: 24,
                icon: Icon(Icons.close, color: theme.colorScheme.primary),
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: content,
            ),
          ),
        ),
      ],
    );
  }
}
