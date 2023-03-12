part of 'edit_task_bloc.dart';

abstract class EditTaskEvent extends Equatable {
  const EditTaskEvent();

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

class EditTaskSubmitted extends EditTaskEvent {
  const EditTaskSubmitted();
}
