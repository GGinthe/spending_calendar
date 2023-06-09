import 'package:table_calendar/table_calendar.dart';
import 'package:tasks_repository/tasks_repository.dart';

enum CalendarTasksFilter { all, activeOnly, completedOnly, deleted, unDeleted }

extension CalendarTasksFilterX on CalendarTasksFilter {
  bool apply(Task task) {
    switch (this) {
      case CalendarTasksFilter.all:
        return true;
      case CalendarTasksFilter.activeOnly:
        return !task.isCompleted;
      case CalendarTasksFilter.completedOnly:
        return task.isCompleted;
      case CalendarTasksFilter.deleted:
        return task.isDeleted;
      case CalendarTasksFilter.unDeleted:
        return !task.isDeleted;
    }
  }

  bool isDay(Task task, DateTime dateTime) {
    return isSameDay(task.startDate, dateTime);
  }

  Iterable<Task> applyAll(Iterable<Task> tasks) {
    return tasks.where(apply);
  }

  bool isBetween(DateTime? startTime, DateTime? endTime, DateTime betweenTime) {
    if(startTime == null || endTime == null){
      return false;
    }
    if (startTime.isBefore(betweenTime) && endTime.isAfter(betweenTime)) {
      return true;
    } else if (isSameDay(startTime, betweenTime) || isSameDay(endTime, betweenTime)) {
      return true;
    }
    return false;
  }

  Iterable<Task> getDayTasks(Iterable<Task> tasks, DateTime dateTime) {
    return tasks.where((task) => isBetween(task.startDate, task.endDate, dateTime));
  }
}
