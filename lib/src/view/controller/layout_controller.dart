import 'package:flutter/material.dart';
import 'package:todo/src/view/pages/mobile/todo_mobile.dart';
import 'package:todo/src/view/pages/web/todo_web.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 700) {
        return const TodoMobile();
      } else {
        return const TodoWeb();
      }
    });
  }
}
