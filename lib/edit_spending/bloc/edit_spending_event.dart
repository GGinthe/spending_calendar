part of 'edit_spending_bloc.dart';

abstract class EditSpendingEvent extends Equatable {
  const EditSpendingEvent();

  @override
  List<Object> get props => [];
}

class EditSpendingTaskInit extends EditSpendingEvent {
  const EditSpendingTaskInit();

  @override
  List<Object> get props => [];
}

class EditSpendingTaskChanged extends EditSpendingEvent {
  const EditSpendingTaskChanged(this.selectedTaskId);

  final String? selectedTaskId;

  @override
  List<Object> get props => [selectedTaskId ?? ''];
}

class EditSpendingTypeChanged extends EditSpendingEvent {
  const EditSpendingTypeChanged();

  @override
  List<Object> get props => [];
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

class EditSpendingIsExpandChanged extends EditSpendingEvent {
  const EditSpendingIsExpandChanged();

  @override
  List<Object> get props => [];
}

class EditSpendingSubmitted extends EditSpendingEvent {
  const EditSpendingSubmitted();
}
