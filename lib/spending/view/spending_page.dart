import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spending_calendar/spending/spending.dart';
import 'package:tasks_repository/tasks_repository.dart';

class SpendingPage extends StatelessWidget {
  const SpendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SpendingBloc(
        tasksRepository: context.read<TasksRepository>(),
      )..add(const SpendingSubscriptionRequested()),
      child: const SpendingView(),
    );
  }
}

class SpendingView extends StatelessWidget {
  const SpendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SpendingBloc>().state;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('花費'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            key: const Key('statsView_completedTasks_listTile'),
            leading: const Icon(Icons.check_rounded),
            title: const Text('完成'),
            trailing: Text(
              '${state.completedTasks}',
              style: textTheme.headlineSmall,
            ),
          ),
          ListTile(
            key: const Key('statsView_activeTasks_listTile'),
            leading: const Icon(Icons.radio_button_unchecked_rounded),
            title: const Text('未完成'),
            trailing: Text(
              '${state.activeTasks}',
              style: textTheme.headlineSmall,
            ),
          ),
        ],
      ),
    );
  }
}
