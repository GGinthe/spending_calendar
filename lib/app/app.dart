import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spending_calendar/home/home.dart';
//import 'package:spending_calendar/l10n/l10n.dart';
import 'package:spending_calendar/app/theme.dart';
import 'package:tasks_repository/tasks_repository.dart';

class App extends StatelessWidget {
  const App({super.key, required this.tasksRepository});

  final TasksRepository tasksRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: tasksRepository,
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FlutterTasksTheme.light,
      darkTheme: FlutterTasksTheme.dark,
      //localizationsDelegates: AppLocalizations.localizationsDelegates,
      //supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}


