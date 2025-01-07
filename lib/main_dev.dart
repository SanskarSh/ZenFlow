// import 'package:drift/native.dart';
// import 'package:todo/src/data/db/dao/dao.dart';
// import 'package:todo/src/data/db/drift_db.dart';

// Future<void> main() async {
  // final db = AppDatabase(NativeDatabase.memory());
  // final todoDao = TodoDao(db);

  // Example usage of the TodoDao:

  // 1. Insert a task:
  // final taskId = await todoDao.insertTask(
  //   const TasksCompanion(
  //     title: Value('Grocery Shopping'),
  //     priority: Value(Priority.high),
  //   ),
  // );
  // print('Inserted task with ID: $taskId');

  // // 2. Insert subtasks related to the new task:
  // await todoDao.insertSubtasks([
  //   SubTasksCompanion(
  //       taskId: Value(taskId.toString()), title: const Value('Buy Milk')),
  //   SubTasksCompanion(
  //       taskId: Value(taskId.toString()), title: const Value('Buy Eggs')),
  // ]);
  // print('Inserted subtasks for task ID: $taskId');

  // // 3. Get all tasks and print them:
  // final allTasks = await todoDao.allTasks.first;
  // print('All Tasks:');
  // allTasks.forEach((value) {
  //   print('Task: ${value.task.title}');
  //   value.subTasks.forEach((subTask) {
  //     print('Subtask: ${subTask.title}');
  //   });
  // });

  // // 4. Get completed tasks and print them (assuming you've marked some as complete):
  // final completedTasks = await todoDao.completedTasks.first;
  // print('\nCompleted Tasks:');
  // completedTasks.forEach(print);

  // // 5. Update a task (e.g., mark it as completed):
  // await todoDao.toggleTaskCompleted(taskId.toString(), true);
  // print('\nTask $taskId marked as completed.');

  // // 6. Get updated list of completed tasks.
  // final updatedCompletedTasks = await todoDao.completedTasks.first;
  // print('\nUpdated Completed Tasks:');
  // updatedCompletedTasks.forEach(print);

  // // 7. Delete a task:
  // await todoDao.deleteTask(taskId.toString());
  // print('\nTask $taskId deleted.');

  // 8. Close the database connection when done
  // await db.close();
// }
// 