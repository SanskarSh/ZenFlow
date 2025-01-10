import 'package:todo/src/core/common/ui_imports.dart';

class DescriptionTextField extends StatelessWidget {
  const DescriptionTextField({super.key, required this.description});

  final RxString description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final descController = TextEditingController(text: description.value).obs;

    ever(descController, (_) => description.value = descController.value.text);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
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
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Additional Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: descController.value,
            style: const TextStyle(
              fontSize: 16,
            ),
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Add notes, subtasks, or any relevant details...',
              hintStyle: TextStyle(color: theme.colorScheme.outline),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              counter: const SizedBox.shrink(),
            ),
            onChanged: (value) => description.value = value,
          ),
        ],
      ),
    );
  }
}
