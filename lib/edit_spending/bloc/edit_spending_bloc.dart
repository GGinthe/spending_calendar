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
            taskId: initialSpending?.taskId,
          ),
        ) {
    on<EditSpendingTaskChanged>(_onTaskChanged);
    on<EditSpendingTitleChanged>(_onTitleChanged);
    on<EditSpendingMoneyChanged>(_onMoneyChanged);
    on<EditSpendingStartDateChanged>(_onStartDateChanged);
    on<EditSpendingSubjectChanged>(_onSubjectChanged);
    on<EditSpendingSubmitted>(_onSubmitted);
  }

  final SpendingRepository _spendingsRepository;
  final TasksRepository _tasksRepository;

  void _onTitleChanged(
    EditSpendingTitleChanged event,
    Emitter<EditSpendingState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onMoneyChanged(
    EditSpendingMoneyChanged event,
    Emitter<EditSpendingState> emit,
  ) {
    emit(state.copyWith(money: event.money));
  }

  Future<void> _onStartDateChanged(
    EditSpendingStartDateChanged event,
    Emitter<EditSpendingState> emit,
  ) async {
    emit(state.copyWith(startDate: event.startDate));
    final taskList = _tasksRepository.getDayTasks(event.startDate);
    emit(state.copyWith(tasks: taskList, taskId: ''));
  }

  void _onTaskChanged(
    EditSpendingTaskChanged event,
    Emitter<EditSpendingState> emit,
  ) {
    emit(state.copyWith(taskId: event.taskId));
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
      taskId: state.taskId,
      title: state.title,
      money: state.money,
      startDate: state.startDate,
      subject: state.subject,
    );

    try {
      await _spendingsRepository.saveSpendings(spending);
      emit(state.copyWith(status: EditSpendingStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditSpendingStatus.failure));
    }
  }
}
