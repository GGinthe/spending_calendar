import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tasks_repository/tasks_repository.dart';

part 'spending_event.dart';

part 'spending_state.dart';

class SpendingBloc extends Bloc<SpendingEvent, SpendingState> {
  SpendingBloc({
    required TasksRepository tasksRepository,
  })  : _tasksRepository = tasksRepository,
        super(const SpendingState()) {
    on<SpendingSubscriptionRequested>(_onSubscriptionRequested);
  }

  final TasksRepository _tasksRepository;

  Future<void> _onSubscriptionRequested(
    SpendingSubscriptionRequested event,
    Emitter<SpendingState> emit,
  ) async {
    emit(state.copyWith(status: SpendingStatus.loading));

    await emit.forEach<List<Task>>(
      _tasksRepository.getTasks(),
      onData: (todos) => state.copyWith(
        status: SpendingStatus.success,
        completedTasks: todos.where((todo) => todo.isCompleted).length,
        activeTasks: todos.where((todo) => !todo.isCompleted).length,
      ),
      onError: (_, __) => state.copyWith(status: SpendingStatus.failure),
    );
  }
}
