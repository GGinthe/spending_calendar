import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasks_repository/tasks_repository.dart';

class TaskListTile extends StatelessWidget {
  const TaskListTile({
    super.key,
    required this.task,
    this.onDismissed,
    this.onTap,
  });

  final Task task;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('taskListTile_dismissible_${task.id}'),
      onDismissed: onDismissed,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(
          Icons.delete,
          color: Color(0xAAFFFFFF),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          dateFormat(task.startDate!, task.endDate!),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        leading: subjectIcon(task.subject ?? '其他'),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}

String dateFormat(DateTime startDate, DateTime endDate) {
  final startText = DateFormat('MM/dd – kk:mm ').format(startDate);
  final endText = DateFormat('MM/dd – kk:mm ').format(endDate);
  return '$startText ~ $endText';
}

Widget subjectIcon(String subject) {
  if (subject == '工作') {
    return const Icon(Icons.work, size: 30);
  } else if (subject == '活動') {
    return const Icon(Icons.event, size: 30);
  } else if (subject == '提醒') {
    return const Icon(Icons.schedule, size: 30);
  } else if (subject == '其他') {
    return const Icon(Icons.bookmark, size: 30);
  }
  return const Icon(Icons.notes, size: 30);
}
