import 'package:flutter/material.dart';
import 'package:todo/src/view/web/todo_web.dart';
import 'package:todo/src/view/mobile/todo_mobile.dart';

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
