import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spending_calendar/home/home.dart';
import 'package:spending_calendar/app/theme.dart';
import 'package:tasks_repository/tasks_repository.dart';
import 'package:spending_repository/spending_repository.dart';

class App extends StatelessWidget {
  const App({super.key, required this.tasksRepository, required this.spendingsRepository});

  final TasksRepository tasksRepository;
  final SpendingRepository spendingsRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: tasksRepository),
        RepositoryProvider.value(value: spendingsRepository),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: FlutterTasksTheme.light,
      darkTheme: FlutterTasksTheme.dark,
      home: const HomePage(),
    );
  }
}
