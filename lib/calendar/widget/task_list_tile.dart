import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tasks_repository/tasks_repository.dart';
import 'package:spending_calendar/icon_select.dart';

import '../bloc/calendar_bloc.dart';

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
    final state = context.watch<CalendarBloc>().state;
    final taskSpending = state.getSpendingsFromTaskID(task.id);
    final taskMoney = [for (var spending in taskSpending) spending.money].fold<int>(0, (a, b) => a + b);
    final moneyColor = taskMoney > 0 ? Colors.green : taskMoney == 0 ? null : Colors.red;

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
            fontSize: 18,
          ),
        ),
        dense: true,
        visualDensity: const VisualDensity(vertical: 0),
        subtitle: Text(
          dateFormat(task.startDate!, task.endDate!),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        leading: taskIcon(task.subject ?? '其他'),
        trailing: Text(
          moneyFormatString(taskMoney),
          style: TextStyle(
            color: moneyColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

String dateFormat(DateTime startDate, DateTime endDate) {
  final startText = DateFormat('MM/dd – kk:mm').format(startDate);
  final endText = DateFormat('MM/dd – kk:mm').format(endDate);
  return '$startText ~ $endText';
}

String moneyFormatString(int money) {
  final moneyI = money < 0 ? money * -1 : money;
  String moneyString = moneyI.toStringAsFixed(0);
  if (moneyI > 9999999999) {
    moneyString = '99+ 億';
  } else if (moneyI > 100000000) {
    moneyString = '${(moneyI / 100000000).toStringAsFixed(2)}億';
  } else if (moneyI > 10000000) {
    moneyString = '${(moneyI / 10000000).toStringAsFixed(1)}千萬';
  } else if (moneyI > 1000000) {
    moneyString = '${(moneyI / 1000000).toStringAsFixed(1)}百萬';
  } else if (moneyI > 100000) {
    moneyString = '${(moneyI / 100000).toStringAsFixed(1)}十萬';
  } else if (moneyI > 10000) {
    moneyString = '${(moneyI / 10000).toStringAsFixed(1)}萬';
  }

  return money < 0 ? '-$moneyString' : moneyString;
}
