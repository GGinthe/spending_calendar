import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spending_calendar/book/book.dart';
import 'package:spending_repository/spending_repository.dart';
import 'package:table_calendar/table_calendar.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookBloc(
        spendingRepository: context.read<SpendingRepository>(),
      )..add(const BookSubscriptionRequested()),
      child: const BookViews(),
    );
  }
}

class BookViews extends StatelessWidget {
  const BookViews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行事曆'),
        /*actions: const [
         BookSpendingsFilterButton(),
         BookSpendingsOptionsButton(),
       ],*/
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BookBloc, BookState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == BookStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('An error occurred while loading spendings.'),
                    ),
                  );
              }
            },
          ),
          BlocListener<BookBloc, BookState>(
            listenWhen: (previous, current) =>
                previous.lastDeletedSpending != current.lastDeletedSpending &&
                current.lastDeletedSpending != null,
            listener: (context, state) {
              final deletedSpending = state.lastDeletedSpending!;
              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      '行程 ${deletedSpending.title} 已刪除',
                    ),
                    action: SnackBarAction(
                      label: '還原',
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        context.read<BookBloc>().add(const BookUndoDeletionRequested());
                      },
                    ),
                  ),
                );
            },
          ),
        ],
        child: BlocBuilder<BookBloc, BookState>(
          builder: (context, state) {
            final DateTime selectedDayState = state.selectedDay ?? DateTime.now();
            DateTime focusedDayState = state.focusedDay ?? DateTime.now();
            CalendarFormat calendarFormatState = state.calendarFormat;

            List<Spending> getSpendingsForDay(DateTime day) {
              return state.getDaySpendings(day).toList();
            }

            return Column(
              children: [
                TableCalendar(
                  focusedDay: focusedDayState,
                  firstDay: DateTime(2005),
                  lastDay: DateTime(2085),
                  calendarFormat: calendarFormatState,
                  locale: 'zh_CN',
                  eventLoader: getSpendingsForDay,
                  daysOfWeekHeight: 20.0,
                  rowHeight: 48.0,
                  pageJumpingEnabled: true,
                  availableCalendarFormats: const {
                    CalendarFormat.month: '月檢視',
                    CalendarFormat.week: '週檢視',
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      events as List<Spending>;
                      final markerText = [for (var spending in events) spending.money]
                          .fold<int>(0, (a, b) => a + b)
                          .toString();
                      if (day.month == selectedDayState.month) {
                        return Container(
                          width: 55,
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
                    },
                  ),
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
                    return isSameDay(selectedDayState, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(selectedDayState, selectedDay)) {
                      context.read<BookBloc>().add(
                            CalendarDaySelected(
                              selectedDay: selectedDay,
                              focusedDay: focusedDay,
                            ),
                          );
                    }
                  },
                  onFormatChanged: (format) {
                    if (calendarFormatState != format) {
                      context.read<BookBloc>().add(
                            CalendarFormatChanged(format),
                          );
                    }
                  },
                  onPageChanged: (focusedDay) {
                    focusedDayState = focusedDay;
                  },
                ),
                const SizedBox(height: 6.0),
                /*CupertinoScrollbar(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final spending in selectedDaySpending)
                        SpendingListTile(
                          spending: spending,
                          onToggleCompleted: (isCompleted) {
                            context.read<BookBloc>().add(
                              BookSpendingCompletionToggled(
                                spending: spending,
                                isCompleted: isCompleted,
                              ),
                            );
                          },
                          onDismissed: (_) {
                            context.read<BookBloc>().add(BookSpendingDeleted(spending));
                          },
                          onTap: () {
                            Navigator.of(context).push(
                              EditSpendingPage.route(initialSpending: spending),
                            );
                          },
                        ),
                    ],
                  ),
                )*/
              ],
            );
          },
        ),
      ),
    );
  }
}
