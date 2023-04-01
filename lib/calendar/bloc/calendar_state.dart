part of 'calendar_bloc.dart';

enum CalendarStatus { initial, loading, success, failure }

class CalendarState extends Equatable {
  const CalendarState({
    this.status = CalendarStatus.initial,
    this.tasks = const [],
    this.spendings = const [],
    this.filter = CalendarTasksFilter.all,
    this.lastDeletedTask,
    this.selectedDay,
    this.focusedDay,
    this.calendarFormat = CalendarFormat.month,
  });

  final CalendarStatus status;
  final List<Task> tasks;
  final List<Spending> spendings;
  final CalendarTasksFilter filter;
  final Task? lastDeletedTask;
  final DateTime? selectedDay;
  final DateTime? focusedDay;
  final CalendarFormat calendarFormat;

  Iterable<Task> get filteredTasks => filter.applyAll(tasks);

  Iterable<Task> getDayTasks(DateTime datetime) => filter.getDayTasks(tasks, datetime);

  Iterable<Spending> getDaySpendings(DateTime dateTime) {
    return spendings.where((spending) => isSameDay(spending.startDate, dateTime));
  }

  Iterable<Spending> getSpendingsFromTaskID(String taskId) {
    return spendings.where((spending) => spending.taskId == taskId);
  }

  CalendarState copyWith({
    CalendarStatus Function()? status,
    List<Task> Function()? tasks,
    List<Spending> Function()? spendings,
    CalendarTasksFilter Function()? filter,
    Task? Function()? lastDeletedTask,
    DateTime? selectedDay,
    DateTime? focusedDay,
    CalendarFormat? calendarFormat,
  }) {
    return CalendarState(
      status: status != null ? status() : this.status,
      tasks: tasks != null ? tasks() : this.tasks,
      spendings: spendings != null ? spendings() : this.spendings,
      filter: filter != null ? filter() : this.filter,
      lastDeletedTask: lastDeletedTask != null ? lastDeletedTask() : this.lastDeletedTask,
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      calendarFormat: calendarFormat ?? this.calendarFormat,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tasks,
        spendings,
        filter,
        lastDeletedTask,
        selectedDay,
        focusedDay,
        calendarFormat,
      ];
}
