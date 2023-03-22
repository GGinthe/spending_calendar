part of 'edit_spending_bloc.dart';

enum EditSpendingStatus { initial, loading, success, failure }

enum SpendingType { income, expenses }

extension EditSpendingStatusX on EditSpendingStatus {
  bool get isLoadingOrSuccess => [
        EditSpendingStatus.loading,
        EditSpendingStatus.success,
      ].contains(this);
}

class EditSpendingState extends Equatable {
  const EditSpendingState({
    this.status = EditSpendingStatus.initial,
    this.spendingType = SpendingType.expenses,
    this.initialSpending,
    this.selectedTaskId,
    this.title = '',
    this.money = 0,
    this.isMoneyFieldCorrect = true,
    this.isTitleFieldCorrect = true,
    this.isTimeFieldCorrect = true,
    this.startDate,
    this.tasks = const [],
    this.subject,
  });

  final EditSpendingStatus status;
  final SpendingType spendingType;
  final Spending? initialSpending;
  final String? selectedTaskId;
  final String title;
  final int money;
  final bool isMoneyFieldCorrect;
  final bool isTitleFieldCorrect;
  final bool isTimeFieldCorrect;
  final DateTime? startDate;
  final List<Task> tasks;
  final String? subject;

  bool get isNewSpending => initialSpending == null;

  Iterable<Task> getDayTasks(List<Task> tasks, DateTime dateTime) {
    return tasks.where((task) => isSameDay(task.startDate, dateTime));
  }

  EditSpendingState copyWith({
    EditSpendingStatus? status,
    SpendingType? spendingType,
    Spending? initialSpending,
    String? selectedTaskId,
    String? title,
    int? money,
    bool? isMoneyFieldCorrect,
    bool? isTitleFieldCorrect,
    bool? isTimeFieldCorrect,
    DateTime? startDate,
    List<Task>? tasks,
    String? subject,
  }) {
    return EditSpendingState(
      status: status ?? this.status,
      spendingType: spendingType ?? this.spendingType,
      initialSpending: initialSpending ?? this.initialSpending,
      selectedTaskId: selectedTaskId ?? this.selectedTaskId,
      title: title ?? this.title,
      money: money ?? this.money,
      isMoneyFieldCorrect: isMoneyFieldCorrect ?? this.isMoneyFieldCorrect,
      isTitleFieldCorrect: isTitleFieldCorrect ?? this.isTitleFieldCorrect,
      isTimeFieldCorrect: isTimeFieldCorrect ?? this.isTimeFieldCorrect,
      startDate: startDate ?? this.startDate,
      tasks: tasks ?? this.tasks,
      subject: subject ?? this.subject,
    );
  }

  @override
  List<Object?> get props => [
        status,
        spendingType,
        initialSpending,
        selectedTaskId,
        title,
        money,
        startDate,
        tasks,
        subject,
        isTitleFieldCorrect,
        isMoneyFieldCorrect,
        isTimeFieldCorrect
      ];
}
