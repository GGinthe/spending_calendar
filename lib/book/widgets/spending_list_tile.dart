import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_repository/spending_repository.dart';
import 'package:tasks_api/tasks_api.dart';
import 'package:spending_calendar/icon_select.dart';

class SpendingListTile extends StatelessWidget {
  const SpendingListTile({
    super.key,
    required this.spending,
    this.onDismissed,
    this.onTap,
  });

  final Spending spending;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moneyFormat = NumberFormat("#,###", "en_US");
    final isIncome = spending.money > 0 ? true : false;
    Color textColor = Colors.green;
    if (isIncome) {
      textColor = Colors.green;
    } else {
      textColor = Colors.red;
    }

    return Dismissible(
      key: Key('spendingListTile_dismissible_${spending.id}'),
      onDismissed: onDismissed,
      direction: onDismissed == null ? DismissDirection.none : DismissDirection.endToStart,
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
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        dense: true,
        visualDensity: const VisualDensity(vertical: 0),
        subtitle: Text(
          spending.title,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        leading: spendingIcon(spending.subject ?? '其他', isIncome ? Colors.green : Colors.red, 30),
        trailing: Text(
          moneyFormat.format(spending.money),
          style: TextStyle(
            color: textColor,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

String getTaskTitleFromID(List<Task> tasks, String taskId) {
  return tasks.firstWhere((task) => task.id == taskId).title;
}
