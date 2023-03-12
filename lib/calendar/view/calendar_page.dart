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
      child: const CalendarView(),
    );
  }
}

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

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
        child: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            /*if (state.tasks.isEmpty) {
              if (state.status == CalendarStatus.loading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state.status != CalendarStatus.success) {
                return const SizedBox();
              } else {
                return Center(
                  child: Text(
                    '無行程',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
            }*/

            final DateTime selectedDayState = state.selectedDay ?? DateTime.now();
            DateTime focusedDayState = state.focusedDay ?? DateTime.now();
            CalendarFormat calendarFormatState = state.calendarFormat;

            List<Task> getTasksForDay(DateTime day) {
              return state.getDayTasks(day).toList();
            }

            List<Task> selectedDayTask = getTasksForDay(selectedDayState);

            return Column(
              children: [
                TableCalendar(
                  focusedDay: focusedDayState,
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  calendarFormat: calendarFormatState,
                  locale: 'zh_CN',
                  eventLoader: getTasksForDay,
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
                ),
                const SizedBox(height: 6.0),
                CupertinoScrollbar(
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
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
