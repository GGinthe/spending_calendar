import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_repository/spending_repository.dart';

class TaskListTile extends StatelessWidget {
  const TaskListTile({
    super.key,
    required this.spending,
    this.onToggleCompleted,
    this.onDismissed,
    this.onTap,
  });

  final Spending spending;
  final ValueChanged<bool>? onToggleCompleted;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionColor = theme.textTheme.bodySmall?.color;

    return Dismissible(
      key: Key('taskListTile_dismissible_${spending.id}'),
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
          spending.subject ?? '其他',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
                  color: captionColor,
                  decoration: TextDecoration.lineThrough,
                ),
        ),
        subtitle: Text(
          DateFormat('yyyy 年 MM 月 dd 日').format(spending.startDate ?? DateTime.now()),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
