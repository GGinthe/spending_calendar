part of 'edit_task_bloc.dart';

enum EditTaskStatus { initial, loading, success, failure }

extension EditTaskStatusX on EditTaskStatus {
  bool get isLoadingOrSuccess =>
      [
        EditTaskStatus.loading,
        EditTaskStatus.success,
      ].contains(this);
}

class EditTaskState extends Equatable {
  const EditTaskState({
    this.status = EditTaskStatus.initial,
    this.initialTask,
    this.title = '',
    this.subject = '其他',
    this.description = '',
    this.isTitleFieldCorrect = true,
    this.isTimeFieldCorrect = true,
    this.startDate,
    this.endDate,
    this.spendings = const [],
  });

  final EditTaskStatus status;
  final Task? initialTask;
  final String title;
  final String subject;
  final bool isTitleFieldCorrect;
  final bool isTimeFieldCorrect;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Spending> spendings;

  bool get isNewTask => initialTask == null;

  Iterable<Spending> getSpendingsFromTaskID(String taskId) {
    return spendings.where((spending) => spending.taskId == taskId);
  }

  EditTaskState copyWith({
    EditTaskStatus? status,
    Task? initialTask,
    String? title,
    String? subject,
    bool? isTitleFieldCorrect,
    bool? isTimeFieldCorrect,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<Spending>? spendings,
  }) {
    return EditTaskState(
      status: status ?? this.status,
      initialTask: initialTask ?? this.initialTask,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      isTitleFieldCorrect: isTitleFieldCorrect ?? this.isTitleFieldCorrect,
      isTimeFieldCorrect: isTimeFieldCorrect ?? this.isTimeFieldCorrect,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      spendings: spendings ?? this.spendings,
    );
  }

  @override
  List<Object?> get props =>
      [
        status,
        initialTask,
        title,
        subject,
        description,
        startDate,
        endDate,
        isTitleFieldCorrect,
        isTimeFieldCorrect,
        spendings
      ];
}
