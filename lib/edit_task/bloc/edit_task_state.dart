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
    this.subject = '其他',
    this.description = '',
    this.isTitleFieldCorrect = true,
    this.isTimeFieldCorrect = true,
    this.isExpand = false,
    this.startDate,
    this.endDate,
    this.spendings = const [],
    this.isBeginCheck = false,
    this.isHourCheck = true,
    this.isDayCheck = false,
    this.isWeekCheck = false,
    this.isCheckExpand = false,
    this.notificationText = 0,
    this.notificationType = '分前',
  });

  final EditTaskStatus status;
  final Task? initialTask;
  final String title;
  final String subject;
  final bool isTitleFieldCorrect;
  final bool isTimeFieldCorrect;
  final bool isExpand;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Spending> spendings;
  final bool isBeginCheck;
  final bool isHourCheck;
  final bool isDayCheck;
  final bool isWeekCheck;
  final bool isCheckExpand;
  final int notificationText;
  final String notificationType;

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
    bool? isExpand,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<Spending>? spendings,
    bool? isBeginCheck,
    bool? isHourCheck,
    bool? isDayCheck,
    bool? isWeekCheck,
    bool? isCheckExpand,
    int? notificationText,
    String? notificationType,
  }) {
    return EditTaskState(
      status: status ?? this.status,
      initialTask: initialTask ?? this.initialTask,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      isTitleFieldCorrect: isTitleFieldCorrect ?? this.isTitleFieldCorrect,
      isTimeFieldCorrect: isTimeFieldCorrect ?? this.isTimeFieldCorrect,
      isExpand: isExpand ?? this.isExpand,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      spendings: spendings ?? this.spendings,
      isHourCheck: isHourCheck ?? this.isHourCheck,
      isBeginCheck: isBeginCheck ?? this.isBeginCheck,
      isDayCheck: isDayCheck ?? this.isDayCheck,
      isWeekCheck: isWeekCheck ?? this.isWeekCheck,
      isCheckExpand: isCheckExpand ?? this.isCheckExpand,
      notificationText: notificationText ?? this.notificationText,
      notificationType: notificationType ?? this.notificationType,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialTask,
        title,
        subject,
        description,
        startDate,
        endDate,
        isTitleFieldCorrect,
        isTimeFieldCorrect,
        isExpand,
        spendings,
        isBeginCheck,
        isHourCheck,
        isDayCheck,
        isWeekCheck,
        isCheckExpand,
        notificationText,
        notificationType,
      ];
}
