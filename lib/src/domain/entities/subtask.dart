class SubTaskEntity {
  final int id;
  final String taskId;
  final String title;
  final String? description;
  bool isCompleted;

  SubTaskEntity({
    required this.taskId,
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
  });
}
