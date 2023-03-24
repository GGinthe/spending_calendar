import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spending_calendar/edit_task/edit_task_view.dart';
import 'package:spending_calendar/calendar/calendar.dart';
import 'package:tasks_repository/tasks_repository.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalendarBloc(
        tasksRepository: context.read<TasksRepository>(),
      )..add(const CalendarSubscriptionRequested()),
      child: const CalendarViews(),
    );
  }
}

class CalendarViews extends StatelessWidget {
  const CalendarViews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行事曆'),
        /*actions: const [
          CalendarTasksFilterButton(),
          CalendarTasksOptionsButton(),
        ],*/
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CalendarBloc, CalendarState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == CalendarStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('An error occurred while loading tasks.'),
                    ),
                  );
              }
            },
          ),
          BlocListener<CalendarBloc, CalendarState>(
            listenWhen: (previous, current) =>
                previous.lastDeletedTask != current.lastDeletedTask && current.lastDeletedTask != null,
            listener: (context, state) {
              final deletedTask = state.lastDeletedTask!;
              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      '行程 ${deletedTask.title} 已刪除',
                    ),
                    action: SnackBarAction(
                      label: '還原',
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        context.read<CalendarBloc>().add(const CalendarUndoDeletionRequested());
                      },
                    ),
                  ),
                );
            },
          ),
        ],
        child: const Column(
          children: [
            _TableCalendar(),
            Expanded(child: _TaskListView()),
          ],
        ),
      ),
    );
  }
}

class _TableCalendar extends StatelessWidget {
  const _TableCalendar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CalendarBloc>().state;
    final DateTime selectedDayState = state.selectedDay ?? DateTime.now();
    DateTime focusedDayState = state.focusedDay ?? DateTime.now();
    CalendarFormat calendarFormatState = state.calendarFormat;

    List<Task> getTasksForDay(DateTime day) {
      return state.getDayTasks(day).toList();
    }

    return TableCalendar(
      focusedDay: focusedDayState,
      firstDay: DateTime(2005),
      lastDay: DateTime(2085),
      calendarFormat: calendarFormatState,
      locale: 'zh_CN',
      eventLoader: getTasksForDay,
      daysOfWeekHeight: 20.0,
      rowHeight: 48.0,
      pageJumpingEnabled: true,
      availableCalendarFormats: const {
        CalendarFormat.month: '月檢視',
        CalendarFormat.week: '週檢視',
      },
      calendarBuilders: CalendarBuilders(markerBuilder: (context, day, events) {
        final markerText = events.length < 10 ? events.length.toString() : '9+';
        if (day.month == selectedDayState.month) {
          return Container(
            width: 40,
            height: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: const Color(0x8777E3FF),
            ),
            child: Text(
              markerText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14.0,
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      }),
      calendarStyle: CalendarStyle(
        markersAutoAligned: false,
        markersAlignment: const Alignment(0, 0.9),
        tableBorder: TableBorder.all(width: 0.8, color: Colors.grey),
        cellMargin: const EdgeInsets.fromLTRB(3, 3, 3, 16),
        cellAlignment: const Alignment(0, -0.7),
        todayDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          color: const Color(0x64330F8B),
        ),
        selectedDecoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          color: Color(0xB1330F8B),
        ),
      ),
      selectedDayPredicate: (day) {
        // Use to determine which day is currently selected.
        // If this returns true, then `day` will be marked as selected.
        return isSameDay(selectedDayState, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(selectedDayState, selectedDay)) {
          // Updating the selected day
          context.read<CalendarBloc>().add(
                CalendarDaySelected(
                  selectedDay: selectedDay,
                  focusedDay: focusedDay,
                ),
              );
        }
      },
      onFormatChanged: (format) {
        if (calendarFormatState != format) {
          // Updating calendar format
          context.read<CalendarBloc>().add(
                CalendarFormatChanged(format),
              );
        }
      },
      onPageChanged: (focusedDay) {
        focusedDayState = focusedDay;
      },
    );
  }
}

class _TaskListView extends StatelessWidget {
  const _TaskListView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CalendarBloc>().state;
    final DateTime selectedDayState = state.selectedDay ?? DateTime.now();
    List<Task> getTasksForDay(DateTime day) {
      return state.getDayTasks(day).toList();
    }

    List<Task> selectedDayTask = getTasksForDay(selectedDayState);
    return CupertinoScrollbar(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final task in selectedDayTask)
            TaskListTile(
              task: task,
              onToggleCompleted: (isCompleted) {
                context.read<CalendarBloc>().add(
                      CalendarTaskCompletionToggled(
                        task: task,
                        isCompleted: isCompleted,
                      ),
                    );
              },
              onDismissed: (_) {
                context.read<CalendarBloc>().add(CalendarTaskDeleted(task));
              },
              onTap: () {
                Navigator.of(context).push(
                  EditTaskPage.route(initialTask: task),
                );
              },
            ),
        ],
      ),
    );
  }
}
