part of 'edit_task_bloc.dart';

abstract class EditTaskEvent extends Equatable {
  const EditTaskEvent();

  @override
  List<Object> get props => [];
}

class EditTaskSpendingInit extends EditTaskEvent {
  const EditTaskSpendingInit();

  @override
  List<Object> get props => [];
}

class EditTaskTitleChanged extends EditTaskEvent {
  const EditTaskTitleChanged(this.title);

  final String title;

  @override
  List<Object> get props => [title];
}

class EditTaskDescriptionChanged extends EditTaskEvent {
  const EditTaskDescriptionChanged(this.description);

  final String description;

  @override
  List<Object> get props => [description];
}

class EditTaskSubjectChanged extends EditTaskEvent {
  const EditTaskSubjectChanged(this.subject);

  final String subject;

  @override
  List<Object> get props => [subject];
}

class EditTaskStartDateChanged extends EditTaskEvent {
  const EditTaskStartDateChanged(this.startDate);

  final DateTime startDate;

  @override
  List<Object> get props => [startDate];
}

class EditTaskEndDateChanged extends EditTaskEvent {
  const EditTaskEndDateChanged(this.endDate);

  final DateTime endDate;

  @override
  List<Object> get props => [endDate];
}

class EditTaskIsExpandChanged extends EditTaskEvent {
  const EditTaskIsExpandChanged();

  @override
  List<Object> get props => [];
}

class EditTaskIsCheckChanged extends EditTaskEvent {
  const EditTaskIsCheckChanged(this.type);
  /// 0: hour, 1: day, 2: week, 3: Expand, 4: Begin
  final int type;

  @override
  List<Object> get props => [type];
}

class EditTaskNotificationTextChanged extends EditTaskEvent {
  const EditTaskNotificationTextChanged(this.notificationText);

  final int notificationText;

  @override
  List<Object> get props => [notificationText];
}

class EditTaskNotificationTypeChanged extends EditTaskEvent {
  const EditTaskNotificationTypeChanged(this.notificationType);

  final String notificationType;

  @override
  List<Object> get props => [notificationType];
}

class EditTaskSubmitted extends EditTaskEvent {
  const EditTaskSubmitted();
}
