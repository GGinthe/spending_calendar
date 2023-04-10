// ignore_for_file: unrelated_type_equality_checks
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:spending_repository/spending_repository.dart';
import 'package:tasks_repository/tasks_repository.dart';
import 'package:spending_calendar/notification/notification.dart';

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
    on<EditTaskIsExpandChanged>(_onExpandChanged);
    on<EditTaskIsCheckChanged>(_onCheckChanged);
    on<EditTaskNotificationTextChanged>(_onNotificationTextChanged);
    on<EditTaskNotificationTypeChanged>(_onNotificationTypeChanged);
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
      if (state.initialTask?.notificationsDuration != null) {
        const int minutesPerWeek = 10080;
        for (var duration in state.initialTask!.notificationsDuration) {
          if (duration.inSeconds == 0 && !state.isBeginCheck) {
            emit(state.copyWith(isBeginCheck: true));
          } else if (duration.inMinutes == Duration.minutesPerHour) {
            if (!state.isHourCheck) {
              emit(state.copyWith(isHourCheck: true));
            }
          } else if (duration.inMinutes == Duration.minutesPerDay) {
            if (!state.isDayCheck) {
              emit(state.copyWith(isDayCheck: true));
            }
          } else if (duration.inMinutes == minutesPerWeek) {
            if (!state.isWeekCheck) {
              emit(state.copyWith(isWeekCheck: true));
            }
          } else {
            final durationText = _durationToString(duration);
            emit(state.copyWith(
                notificationText: int.tryParse(durationText.first), notificationType: durationText.last));
          }
        }
      }
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

  void _onCheckChanged(
    EditTaskIsCheckChanged event,
    Emitter<EditTaskState> emit,
  ) {
    if (event.type == 0) {
      emit(state.copyWith(isHourCheck: !state.isHourCheck));
    } else if (event.type == 1) {
      emit(state.copyWith(isDayCheck: !state.isDayCheck));
    } else if (event.type == 2) {
      emit(state.copyWith(isWeekCheck: !state.isWeekCheck));
    } else if (event.type == 3) {
      emit(state.copyWith(isCheckExpand: !state.isCheckExpand));
    } else if (event.type == 4) {
      emit(state.copyWith(isBeginCheck: !state.isBeginCheck));
    }
  }

  void _onExpandChanged(
    EditTaskIsExpandChanged event,
    Emitter<EditTaskState> emit,
  ) {
    emit(state.copyWith(isExpand: !state.isExpand));
  }

  void _onNotificationTextChanged(
    EditTaskNotificationTextChanged event,
    Emitter<EditTaskState> emit,
  ) {
    emit(state.copyWith(notificationText: event.notificationText));
  }

  void _onNotificationTypeChanged(
    EditTaskNotificationTypeChanged event,
    Emitter<EditTaskState> emit,
  ) {
    emit(state.copyWith(notificationType: event.notificationType));
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

    if (state.initialTask?.notificationsId != null) {
      for (var notificationId in state.initialTask!.notificationsId) {
        notification.cancelNotification(notificationId);
      }
    }

    final List<Duration?> notificationDurationNull = [
      if (state.isHourCheck) const Duration(hours: 1),
      if (state.isDayCheck) const Duration(days: 1),
      if (state.isWeekCheck) const Duration(days: 7),
      if (state.isBeginCheck) Duration.zero,
      if (state.notificationText != '0' && state.notificationText != '')
        _stringToDuration(state.notificationType, state.notificationText)
    ];
    final List<Duration> notificationDuration = notificationDurationNull.whereType<Duration>().toList();
    List<int> notificationId = [];
    Random random = Random();
    for (var duration in notificationDuration) {
      final id = random.nextInt(2147483647);
      final date = state.startDate!.subtract(duration);
      // add notification if earlier than now
      if (date.isAfter(DateTime.now())) {
        notification.scheduleNotification(id, state.title, _dateFormat(state.startDate, state.endDate), date,
            payload: state.initialTask?.id);
      }
      notificationId.add(id);
    }

    try {
      await Future.wait([
        _tasksRepository.saveTask(
            task.copyWith(notificationsId: notificationId, notificationsDuration: notificationDuration)),
        if (state.initialTask != null) ...[
          _spendingsRepository.editSpendingDateByTask(
              taskId: state.initialTask!.id, startTime: task.startDate!, endTime: task.endDate!),
        ],
      ]);
      emit(state.copyWith(status: EditTaskStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditTaskStatus.failure));
    }
  }

  Duration? _stringToDuration(String type, int time) {
    Duration? duration;
    if (type == '分前') {
      duration = Duration(minutes: time);
    } else if (type == '小時前') {
      duration = Duration(hours: time);
    } else if (type == '天前') {
      duration = Duration(days: time);
    } else if (type == '週前') {
      duration = Duration(days: time * 7);
    } else if (type == '月前') {
      duration = Duration(days: time * 30);
    }
    if (duration?.inMinutes == Duration.minutesPerHour ||
        duration?.inMinutes == Duration.minutesPerDay ||
        duration?.inMinutes == 10080) {
      return null;
    }
    return duration;
  }

  String _dateFormat(DateTime? startDate, DateTime? endDate) {
    final startText = startDate != null ? DateFormat('MM/dd – kk:mm').format(startDate) : '';
    final endText = endDate != null ? DateFormat('MM/dd – kk:mm').format(endDate) : '';
    return '$startText ~ $endText';
  }

  List<String> _durationToString(Duration duration) {
    if (duration.inDays >= 30 && duration.inDays % 30 == 0) {
      return [(duration.inDays / 30).toString(), '月前'];
    }
    if (duration.inDays >= 7 && duration.inDays % 7 == 0) {
      return [(duration.inDays / 7).toString(), '週前'];
    }
    if (duration.inHours >= 24 && duration.inHours % 24 == 0) {
      return [(duration.inHours / 24).toString(), '天前'];
    }
    if (duration.inMinutes >= 60 && duration.inMinutes % 60 == 0) {
      return [(duration.inHours).toString(), '小時前'];
    }
    return [duration.inMinutes.toString(), '分前'];
  }
}
