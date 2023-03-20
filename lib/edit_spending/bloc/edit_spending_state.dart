part of 'edit_spending_bloc.dart';

enum EditSpendingStatus { initial, loading, success, failure }

extension EditSpendingStatusX on EditSpendingStatus {
  bool get isLoadingOrSuccess => [
        EditSpendingStatus.loading,
        EditSpendingStatus.success,
      ].contains(this);
}

class EditSpendingState extends Equatable {
  const EditSpendingState({
    this.status = EditSpendingStatus.initial,
    this.initialSpending,
    this.taskId,
    this.title = '',
    this.money = 0,
    this.startDate,
    this.tasks = const [],
    this.subject,
  });

  final EditSpendingStatus status;
  final Spending? initialSpending;
  final String? taskId;
  final String title;
  final int money;
  final DateTime? startDate;
  final List<Task> tasks;
  final String? subject;

  bool get isNewSpending => initialSpending == null;

  Iterable<Task> getDayTasks(List<Task> tasks, DateTime dateTime) {
    return tasks.where((task) => isSameDay(task.startDate, dateTime));
  }

  EditSpendingState copyWith({
    EditSpendingStatus? status,
    Spending? initialSpending,
    String? taskId,
    String? title,
    int? money,
    DateTime? startDate,
    List<Task>? tasks,
    String? subject,
  }) {
    return EditSpendingState(
      status: status ?? this.status,
      initialSpending: initialSpending ?? this.initialSpending,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      money: money ?? this.money,
      startDate: startDate ?? this.startDate,
      tasks: tasks ?? this.tasks,
      subject: subject ?? this.subject,
    );
  }

  @override
  List<Object?> get props => [status, initialSpending, taskId, title, money, startDate, tasks, subject];
}
