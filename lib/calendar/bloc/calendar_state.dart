part of 'calendar_bloc.dart';

enum CalendarStatus { initial, loading, success, failure }

class CalendarState extends Equatable {
  const CalendarState({
    this.status = CalendarStatus.initial,
    this.tasks = const [],
    this.filter = CalendarTasksFilter.all,
    this.lastDeletedTask,
    this.selectedDay,
    this.focusedDay,
    this.calendarFormat = CalendarFormat.month,
  });

  final CalendarStatus status;
  final List<Task> tasks;
  final CalendarTasksFilter filter;
  final Task? lastDeletedTask;
  final DateTime? selectedDay;
  final DateTime? focusedDay;
  final CalendarFormat calendarFormat;

  Iterable<Task> get filteredTasks => filter.applyAll(tasks);

  Iterable<Task> getDayTasks(DateTime datetime) => filter.getDayTasks(tasks, datetime);

  CalendarState copyWith({
    CalendarStatus Function()? status,
    List<Task> Function()? tasks,
    CalendarTasksFilter Function()? filter,
    Task? Function()? lastDeletedTask,
    DateTime? selectedDay,
    DateTime? focusedDay,
    CalendarFormat? calendarFormat,
  }) {
    return CalendarState(
      status: status != null ? status() : this.status,
      tasks: tasks != null ? tasks() : this.tasks,
      filter: filter != null ? filter() : this.filter,
      lastDeletedTask: lastDeletedTask != null ? lastDeletedTask() : this.lastDeletedTask,
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      //calendarFormat: calendarFormat ?? this.calendarFormat,
      calendarFormat: calendarFormat ?? this.calendarFormat,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tasks,
        filter,
        lastDeletedTask,
        selectedDay,
        focusedDay,
        calendarFormat,
      ];
}
