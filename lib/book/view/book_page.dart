import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:spending_calendar/edit_spending/edit_spending_view.dart';
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
            previous.lastDeletedSpending != current.lastDeletedSpending && current.lastDeletedSpending != null,
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

            List<Spending> selectedDaySpending = getSpendingsForDay(selectedDayState);

            return Column(
              children: [
                TableCalendar(
                  focusedDay: focusedDayState,
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  calendarFormat: calendarFormatState,
                  locale: 'zh_CN',
                  eventLoader: getSpendingsForDay,
                  selectedDayPredicate: (day) {
                    // Use to determine which day is currently selected.
                    // If this returns true, then `day` will be marked as selected.
                    return isSameDay(selectedDayState, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(selectedDayState, selectedDay)) {
                      // Updating the selected day
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
                      // Updating book format
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


