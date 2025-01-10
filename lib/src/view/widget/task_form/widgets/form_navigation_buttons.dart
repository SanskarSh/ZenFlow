import 'package:todo/src/core/common/ui_imports.dart';

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
                onPressed: submitForm,
              )
          ],
        ),
      ),
    );
  }
}
