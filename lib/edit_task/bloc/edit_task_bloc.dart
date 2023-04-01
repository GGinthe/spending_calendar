import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spending_repository/spending_repository.dart';
import 'package:tasks_repository/tasks_repository.dart';

part 'edit_task_event.dart';

part 'edit_task_state.dart';

class EditTaskBloc extends Bloc<EditTaskEvent, EditTaskState> {
  EditTaskBloc({
    required SpendingRepository spendingsRepository,
    required TasksRepository tasksRepository,
    required Task? initialTask,
  })  : _spendingsRepository = spendingsRepository,
        _tasksRepository = tasksRepository,
        super(
          EditTaskState(
            initialTask: initialTask,
            title: initialTask?.title ?? '',
            subject: initialTask?.subject ?? '其他',
            description: initialTask?.description ?? '',
            startDate: initialTask?.startDate,
            endDate: initialTask?.endDate,
          ),
        ) {
    on<EditTaskSpendingInit>(_onInit);
    on<EditTaskTitleChanged>(_onTitleChanged);
    on<EditTaskDescriptionChanged>(_onDescriptionChanged);
    on<EditTaskStartDateChanged>(_onStartDateChanged);
    on<EditTaskEndDateChanged>(_onEndDateChanged);
    on<EditTaskSubmitted>(_onSubmitted);
    on<EditTaskSubjectChanged>(_onSubjectChanged);
  }

  final SpendingRepository _spendingsRepository;
  final TasksRepository _tasksRepository;

  void _onInit(
    EditTaskSpendingInit event,
    Emitter<EditTaskState> emit,
  ) {
    if (state.initialTask != null) {
      final spendingList = _spendingsRepository.getSpendingsFromTaskID(state.initialTask!.id);
      emit(state.copyWith(spendings: spendingList));
    }
  }

  void _onTitleChanged(
    EditTaskTitleChanged event,
    Emitter<EditTaskState> emit,
  ) {
    if (!state.isTitleFieldCorrect && event.title.isNotEmpty) {
      emit(state.copyWith(isTitleFieldCorrect: true));
    }
    emit(state.copyWith(title: event.title));
  }

  void _onDescriptionChanged(
    EditTaskDescriptionChanged event,
    Emitter<EditTaskState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onSubjectChanged(
    EditTaskSubjectChanged event,
    Emitter<EditTaskState> emit,
  ) {
    emit(state.copyWith(subject: event.subject));
  }

  void _onStartDateChanged(
    EditTaskStartDateChanged event,
    Emitter<EditTaskState> emit,
  ) {
    emit(state.copyWith(startDate: event.startDate));

    if (!state.isTimeFieldCorrect) {
      emit(state.copyWith(isTimeFieldCorrect: true));
    }

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

    if (!state.isTimeFieldCorrect) {
      emit(state.copyWith(isTimeFieldCorrect: true));
    }

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
      subject: state.subject,
      startDate: state.startDate,
      endDate: state.endDate,
    );

    bool isError = false;
    if (task.title.isEmpty) {
      emit(state.copyWith(isTitleFieldCorrect: false));
      isError = true;
    }
    if (task.startDate == null) {
      emit(state.copyWith(isTimeFieldCorrect: false));
      isError = true;
    }
    if (isError) {
      emit(state.copyWith(status: EditTaskStatus.failure));
      return;
    }
    try {
      await Future.wait([
        _tasksRepository.saveTask(task),
        if (state.initialTask != null) ...[
          _spendingsRepository.editSpendingDateByTask(
              taskId: state.initialTask!.id, startTime: task.startDate!, endTime: task.endDate!),
        ]
      ]);
      emit(state.copyWith(status: EditTaskStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditTaskStatus.failure));
    }
  }
}
