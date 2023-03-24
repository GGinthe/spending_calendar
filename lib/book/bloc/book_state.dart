part of 'book_bloc.dart';

enum BookStatus { initial, loading, success, failure }

class BookState extends Equatable {
  const BookState({
    this.status = BookStatus.initial,
    this.spendings = const [],
    this.filter = BookSpendingsFilter.all,
    this.lastDeletedSpending,
    this.selectedDay,
    this.focusedDay,
    this.calendarFormat = CalendarFormat.month,
  });

  final BookStatus status;
  final List<Spending> spendings;
  final BookSpendingsFilter filter;
  final Spending? lastDeletedSpending;
  final DateTime? selectedDay;
  final DateTime? focusedDay;
  final CalendarFormat calendarFormat;

  Iterable<Spending> get filteredSpendings => filter.applyAll(spendings);

  Iterable<Spending> getDaySpendings(DateTime datetime) => filter.getDaySpendings(spendings, datetime);

  BookState copyWith({
    BookStatus Function()? status,
    List<Spending> Function()? spendings,
    BookSpendingsFilter Function()? filter,
    Spending? Function()? lastDeletedSpending,
    DateTime? selectedDay,
    DateTime? focusedDay,
    CalendarFormat? calendarFormat,
  }) {
    return BookState(
      status: status != null ? status() : this.status,
      spendings: spendings != null ? spendings() : this.spendings,
      filter: filter != null ? filter() : this.filter,
      lastDeletedSpending: lastDeletedSpending != null ? lastDeletedSpending() : this.lastDeletedSpending,
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      calendarFormat: calendarFormat ?? this.calendarFormat,
    );
  }

  @override
  List<Object?> get props => [
        status,
        spendings,
        filter,
        lastDeletedSpending,
        selectedDay,
        focusedDay,
        calendarFormat,
      ];
}
