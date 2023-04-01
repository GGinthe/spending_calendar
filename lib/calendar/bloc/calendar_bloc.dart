import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spending_calendar/calendar/calendar.dart';
import 'package:spending_repository/spending_repository.dart';
import 'package:tasks_repository/tasks_repository.dart';
import 'package:table_calendar/table_calendar.dart';

part 'calendar_event.dart';

part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc({
    required SpendingRepository spendingsRepository,
    required TasksRepository tasksRepository,
  })  : _spendingsRepository = spendingsRepository,
        _tasksRepository = tasksRepository,
        super(const CalendarState()) {
    on<CalendarSubscriptionRequested>(_onSubscriptionRequested);
    on<CalendarTaskCompletionToggled>(_onTaskCompletionToggled);
    on<CalendarTaskDeleted>(_onTaskDeleted);
    on<CalendarUndoDeletionRequested>(_onUndoDeletionRequested);
    on<CalendarFilterChanged>(_onFilterChanged);
    on<CalendarToggleAllRequested>(_onToggleAllRequested);
    on<CalendarClearCompletedRequested>(_onClearCompletedRequested);
    on<CalendarDaySelected>(_onCalendarDaySelected);
    on<CalendarFormatChanged>(_onCalendarFormatChanged);
  }

  final TasksRepository _tasksRepository;
  final SpendingRepository _spendingsRepository;

  Future<void> _onSubscriptionRequested(
    CalendarSubscriptionRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(status: () => CalendarStatus.loading));

    await Future.wait([
      emit.forEach<List<Task>>(
        _tasksRepository.getTasks(),
        onData: (tasks) => state.copyWith(
          status: () => CalendarStatus.success,
          tasks: () => tasks,
        ),
        onError: (_, __) => state.copyWith(
          status: () => CalendarStatus.failure,
        ),
      ),
      emit.forEach<List<Spending>>(
        _spendingsRepository.getSpendings(),
        onData: (spendings) => state.copyWith(
          status: () => CalendarStatus.success,
          spendings: () => spendings,
        ),
        onError: (_, __) => state.copyWith(
          status: () => CalendarStatus.failure,
        ),
      )
    ]);
  }

  Future<void> _onTaskCompletionToggled(
    CalendarTaskCompletionToggled event,
    Emitter<CalendarState> emit,
  ) async {
    final newTask = event.task.copyWith(isCompleted: event.isCompleted);
    await _tasksRepository.saveTask(newTask);
  }

  Future<void> _onTaskDeleted(
    CalendarTaskDeleted event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(lastDeletedTask: () => event.task));
    await _tasksRepository.deleteTask(event.task.id);
  }

  Future<void> _onUndoDeletionRequested(
    CalendarUndoDeletionRequested event,
    Emitter<CalendarState> emit,
  ) async {
    assert(
      state.lastDeletedTask != null,
      'Last deleted task can not be null.',
    );

    final task = state.lastDeletedTask!;
    emit(state.copyWith(lastDeletedTask: () => null));
    await _tasksRepository.saveTask(task);
  }

  void _onFilterChanged(
    CalendarFilterChanged event,
    Emitter<CalendarState> emit,
  ) {
    emit(state.copyWith(filter: () => event.filter));
  }

  Future<void> _onToggleAllRequested(
    CalendarToggleAllRequested event,
    Emitter<CalendarState> emit,
  ) async {
    final areAllCompleted = state.tasks.every((task) => task.isCompleted);
    await _tasksRepository.completeAll(isCompleted: !areAllCompleted);
  }

  Future<void> _onClearCompletedRequested(
    CalendarClearCompletedRequested event,
    Emitter<CalendarState> emit,
  ) async {
    await _tasksRepository.clearCompleted();
  }

  void _onCalendarDaySelected(
    CalendarDaySelected event,
    Emitter<CalendarState> emit,
  ) {
    emit(state.copyWith(selectedDay: event.selectedDay, focusedDay: event.focusedDay));
  }

  void _onCalendarFormatChanged(
    CalendarFormatChanged event,
    Emitter<CalendarState> emit,
  ) {
    emit(state.copyWith(calendarFormat: event.calendarFormat));
  }
}
