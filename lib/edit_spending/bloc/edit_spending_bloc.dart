import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spending_repository/spending_repository.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tasks_repository/tasks_repository.dart';

part 'edit_spending_event.dart';

part 'edit_spending_state.dart';

class EditSpendingBloc extends Bloc<EditSpendingEvent, EditSpendingState> {
  EditSpendingBloc({
    required SpendingRepository spendingsRepository,
    required TasksRepository tasksRepository,
    required Spending? initialSpending,
  })  : _spendingsRepository = spendingsRepository,
        _tasksRepository = tasksRepository,
        super(
          EditSpendingState(
            initialSpending: initialSpending,
            title: initialSpending?.title ?? '',
            startDate: initialSpending?.startDate,
            selectedTaskId: initialSpending?.taskId,
            money: initialSpending?.money ?? 0,
          ),
        ) {
    on<EditSpendingTaskChanged>(_onTaskChanged);
    on<EditSpendingTypeChanged>(_onTypeChanged);
    on<EditSpendingTitleChanged>(_onTitleChanged);
    on<EditSpendingMoneyChanged>(_onMoneyChanged);
    on<EditSpendingStartDateChanged>(_onStartDateChanged);
    on<EditSpendingSubjectChanged>(_onSubjectChanged);
    on<EditSpendingSubmitted>(_onSubmitted);
  }

  final SpendingRepository _spendingsRepository;
  final TasksRepository _tasksRepository;

  Task getTaskFromID(List<Task> tasks, String taskId) {
    return tasks.firstWhere((task) => task.id == taskId);
  }

  void _onTitleChanged(
    EditSpendingTitleChanged event,
    Emitter<EditSpendingState> emit,
  ) {
    if (!state.isTitleFieldCorrect && event.title.isNotEmpty) {
      emit(state.copyWith(isTitleFieldCorrect: true));
    }
    emit(state.copyWith(title: event.title));
  }

  void _onMoneyChanged(
    EditSpendingMoneyChanged event,
    Emitter<EditSpendingState> emit,
  ) {
    if (!state.isMoneyFieldCorrect && event.money != 0) {
      emit(state.copyWith(isMoneyFieldCorrect: true));
    }
    emit(state.copyWith(money: event.money));
  }

  void _onTypeChanged(
      EditSpendingTypeChanged event,
      Emitter<EditSpendingState> emit,
      ) {
    if (state.spendingType == SpendingType.expenses) {
      emit(state.copyWith(spendingType: SpendingType.income));
    }
    else{
      emit(state.copyWith(spendingType: SpendingType.expenses));
    }
  }

  Future<void> _onStartDateChanged(
    EditSpendingStartDateChanged event,
    Emitter<EditSpendingState> emit,
  ) async {
    if (!state.isTimeFieldCorrect) {
      emit(state.copyWith(isTimeFieldCorrect: true));
    }
    emit(state.copyWith(startDate: event.startDate));
    final taskList = _tasksRepository.getDayTasks(event.startDate);
    emit(state.copyWith(tasks: taskList, selectedTaskId: ''));

  }

  void _onTaskChanged(
    EditSpendingTaskChanged event,
    Emitter<EditSpendingState> emit,
  ) {
    emit(state.copyWith(selectedTaskId: event.selectedTaskId));
  }

  void _onSubjectChanged(
    EditSpendingSubjectChanged event,
    Emitter<EditSpendingState> emit,
  ) {
    emit(state.copyWith(subject: event.subject));
  }

  Future<void> _onSubmitted(
    EditSpendingSubmitted event,
    Emitter<EditSpendingState> emit,
  ) async {
    emit(state.copyWith(status: EditSpendingStatus.loading));
    final spending = (state.initialSpending ?? Spending(title: '', money: 0)).copyWith(
      taskId: state.selectedTaskId,
      title: state.title,
      money: state.money,
      startDate: state.startDate,
      subject: state.subject,
    );

    bool isError = false;
    if (spending.money == 0) {
      emit(state.copyWith(isMoneyFieldCorrect: false));
      isError = true;
    }
    if (spending.title.isEmpty) {
      emit(state.copyWith(isTitleFieldCorrect: false));
      isError = true;
    }
    if (spending.startDate == null) {
      emit(state.copyWith(isTimeFieldCorrect: false));
      isError = true;
    }
    if (isError) {
      emit(state.copyWith(status: EditSpendingStatus.failure));
      return;
    }

    try {
      await _spendingsRepository.saveSpendings(spending);
      emit(state.copyWith(status: EditSpendingStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditSpendingStatus.failure));
    }
  }
}
