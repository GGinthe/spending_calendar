part of 'edit_task_bloc.dart';

enum EditTaskStatus { initial, loading, success, failure }

extension EditTaskStatusX on EditTaskStatus {
  bool get isLoadingOrSuccess => [
    EditTaskStatus.loading,
    EditTaskStatus.success,
  ].contains(this);
}

class EditTaskState extends Equatable {
  const EditTaskState({
    this.status = EditTaskStatus.initial,
    this.initialTask,
    this.title = '',
    this.description = '',
    this.startDate,
    this.endDate,
  });

  final EditTaskStatus status;
  final Task? initialTask;
  final String title;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get isNewTask => initialTask == null;

  EditTaskState copyWith({
    EditTaskStatus? status,
    Task? initialTask,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return EditTaskState(
      status: status ?? this.status,
      initialTask: initialTask ?? this.initialTask,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [status, initialTask, title, description, startDate, endDate];
}

