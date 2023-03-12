part of 'calendar_bloc.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object> get props => [];
}

/// Startup event.
/// In response, the bloc subscribes to the stream of tasks from the TasksRepository.
class CalendarSubscriptionRequested extends CalendarEvent {
  const CalendarSubscriptionRequested();
}

/// This toggles a task's completed status.
class CalendarTaskCompletionToggled extends CalendarEvent {
  const CalendarTaskCompletionToggled({
    required this.task,
    required this.isCompleted,
  });

  final Task task;
  final bool isCompleted;

  @override
  List<Object> get props => [task, isCompleted];
}

/// This deletes a Task.
class CalendarTaskDeleted extends CalendarEvent {
  const CalendarTaskDeleted(this.task);

  final Task task;

  @override
  List<Object> get props => [task];
}

/// This undoes a task deletion, e.g. an accidental deletion.
class CalendarUndoDeletionRequested extends CalendarEvent {
  const CalendarUndoDeletionRequested();
}

/// This takes a CalendarTasksFilter as an argument and changes the view
/// by applying a filter.
class CalendarFilterChanged extends CalendarEvent {
  const CalendarFilterChanged(this.filter);

  final CalendarTasksFilter filter;

  @override
  List<Object> get props => [filter];
}

/// This toggles completion for all tasks.
class CalendarToggleAllRequested extends CalendarEvent {
  const CalendarToggleAllRequested();
}

/// This deletes all completed tasks.
class CalendarClearCompletedRequested extends CalendarEvent {
  const CalendarClearCompletedRequested();
}

class CalendarDaySelected extends CalendarEvent {
  const CalendarDaySelected(
      {required this.selectedDay, required this.focusedDay});

  final DateTime selectedDay;
  final DateTime focusedDay;

  @override
  List<Object> get props => [selectedDay, focusedDay];
}

class CalendarFormatChanged extends CalendarEvent {
  const CalendarFormatChanged(this.calendarFormat);

  final CalendarFormat calendarFormat;

  @override
  List<Object> get props => [calendarFormat];
}