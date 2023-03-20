part of 'edit_spending_bloc.dart';

abstract class EditSpendingEvent extends Equatable {
  const EditSpendingEvent();

  @override
  List<Object> get props => [];
}

class EditSpendingTaskChanged extends EditSpendingEvent {
  const EditSpendingTaskChanged(this.taskId);

  final String? taskId;

  @override
  List<Object> get props => [taskId ?? ''];
}

class EditSpendingTitleChanged extends EditSpendingEvent {
  const EditSpendingTitleChanged(this.title);

  final String title;

  @override
  List<Object> get props => [title];
}

class EditSpendingMoneyChanged extends EditSpendingEvent {
  const EditSpendingMoneyChanged(this.money);

  final int money;

  @override
  List<Object> get props => [money];
}

class EditSpendingStartDateChanged extends EditSpendingEvent {
  const EditSpendingStartDateChanged(this.startDate);

  final DateTime startDate;

  @override
  List<Object> get props => [startDate];
}

class EditSpendingSubjectChanged extends EditSpendingEvent {
  const EditSpendingSubjectChanged(this.subject);

  final String subject;

  @override
  List<Object> get props => [subject];
}

class EditSpendingSubmitted extends EditSpendingEvent {
  const EditSpendingSubmitted();
}
