import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spending_repository/spending_repository.dart';
import 'package:tasks_api/tasks_api.dart';

import '../bloc/book_bloc.dart';

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
    final state = context.watch<BookBloc>().state;
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
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          spending.title,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        leading: subjectIcon(spending.subject ?? '其他', isIncome),
        trailing: Text(
          spending.money.toString(),
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

Widget subjectIcon(String subject, bool isIncome) {
  const double iconSize = 30;
  Color iconColor = Colors.green;
  if (isIncome) {
    iconColor = Colors.green;
  } else {
    iconColor = Colors.red;
  }

  if (subject == '其他') {
    return Icon(Icons.work, size: iconSize, color: iconColor,);
  } else if (subject == '早餐') {
    return Icon(Icons.breakfast_dining, size: iconSize, color: iconColor,);
  } else if (subject == '午餐') {
    return Icon(Icons.dinner_dining, size: iconSize, color: iconColor,);
  } else if (subject == '晚餐') {
    return Icon(Icons.lunch_dining, size: iconSize, color: iconColor,);
  } else if (subject == '飲品') {
    return Icon(Icons.wine_bar, size: iconSize, color: iconColor,);
  } else if (subject == '交通') {
    return Icon(Icons.train, size: iconSize, color: iconColor,);
  } else if (subject == '購物') {
    return Icon(Icons.shopping_bag, size: iconSize, color: iconColor,);
  } else if (subject == '房租') {
    return Icon(Icons.house, size: iconSize, color: iconColor,);
  } else if (subject == '社交') {
    return Icon(Icons.people, size: iconSize, color: iconColor,);
  }
  return Icon(Icons.notes, size: iconSize, color: iconColor,);
}
