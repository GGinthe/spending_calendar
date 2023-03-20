import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tasks_repository/tasks_repository.dart';

part 'edit_task_event.dart';

part 'edit_task_state.dart';

class EditTaskBloc extends Bloc<EditTaskEvent, EditTaskState> {
  EditTaskBloc({
    required TasksRepository tasksRepository,
    required Task? initialTask,
  })  : _tasksRepository = tasksRepository,
        super(
          EditTaskState(
            initialTask: initialTask,
            title: initialTask?.title ?? '',
            description: initialTask?.description ?? '',
            startDate: initialTask?.startDate,
            endDate: initialTask?.endDate,
          ),
        ) {
    on<EditTaskTitleChanged>(_onTitleChanged);
    on<EditTaskDescriptionChanged>(_onDescriptionChanged);
    on<EditTaskStartDateChanged>(_onStartDateChanged);
    on<EditTaskEndDateChanged>(_onEndDateChanged);
    on<EditTaskSubmitted>(_onSubmitted);
  }

  final TasksRepository _tasksRepository;

  void _onTitleChanged(
    EditTaskTitleChanged event,
    Emitter<EditTaskState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onDescriptionChanged(
    EditTaskDescriptionChanged event,
    Emitter<EditTaskState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onStartDateChanged(
    EditTaskStartDateChanged event,
    Emitter<EditTaskState> emit,
  ) {
    emit(state.copyWith(startDate: event.startDate));
    if (state.endDate == null) {
      emit(state.copyWith(endDate: event.startDate.add(const Duration(hours: 1))));
    }
    // If endDate before startDate, emit endDate = startData + 1
    else if (state.endDate!.isBefore(event.startDate)) {
      emit(state.copyWith(endDate: event.startDate.add(const Duration(hours: 1))));
    }
  }

  void _onEndDateChanged(
    EditTaskEndDateChanged event,
    Emitter<EditTaskState> emit,
  ) {
    emit(state.copyWith(endDate: event.endDate));
    if (state.startDate == null) {
      emit(state.copyWith(startDate: event.endDate.subtract(const Duration(hours: 1))));
    }
    // If endDate before startDate, emit startDate = endData - 1
    else if (event.endDate.isBefore(state.startDate!)) {
      emit(state.copyWith(startDate: event.endDate.subtract(const Duration(hours: 1))));
    }
  }

  Future<void> _onSubmitted(
    EditTaskSubmitted event,
    Emitter<EditTaskState> emit,
  ) async {
    emit(state.copyWith(status: EditTaskStatus.loading));
    final task = (state.initialTask ?? Task(title: '')).copyWith(
      title: state.title,
      description: state.description,
      startDate: state.startDate,
      endDate: state.endDate,
    );

    try {
      await _tasksRepository.saveTask(task);
      emit(state.copyWith(status: EditTaskStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditTaskStatus.failure));
    }
  }
}
