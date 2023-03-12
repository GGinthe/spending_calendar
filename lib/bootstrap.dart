import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:spending_calendar/app/app.dart';
import 'package:spending_calendar/app/app_bloc_observer.dart';
import 'package:tasks_api/tasks_api.dart';
import 'package:tasks_repository/tasks_repository.dart';

void bootstrap({required TasksApi tasksApi}) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  final tasksRepository = TasksRepository(tasksApi: tasksApi);

  runZonedGuarded(
        () => runApp(App(tasksRepository: tasksRepository)),
        (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}



