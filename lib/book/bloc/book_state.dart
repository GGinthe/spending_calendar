part of 'book_bloc.dart';

enum BookStatus { initial, loading, success, failure }

enum BalanceStatus { total, separate }

class BookState extends Equatable {
  const BookState({
    this.status = BookStatus.initial,
    this.balanceStatus = BalanceStatus.separate,
    this.spendings = const [],
    this.filter = BookSpendingsFilter.all,
    this.lastDeletedSpending,
    this.selectedDay,
    this.focusedDay,
    this.calendarFormat = CalendarFormat.month,
  });

  final BookStatus status;
  final BalanceStatus balanceStatus;
  final List<Spending> spendings;
  final BookSpendingsFilter filter;
  final Spending? lastDeletedSpending;
  final DateTime? selectedDay;
  final DateTime? focusedDay;
  final CalendarFormat calendarFormat;

  Iterable<Spending> get filteredSpendings => filter.applyAll(spendings);

  Iterable<Spending> getDaySpendings(DateTime datetime) => filter.getDaySpendings(spendings, datetime);

  List<int> getDayTotal(DateTime datetime) => filter.getDayTotal(spendings, datetime);

  List<int> getWeekTotal(DateTime datetime) => filter.getWeekTotal(spendings, datetime);

  List<int> getMonthTotal(DateTime datetime) => filter.getMonthTotal(spendings, datetime);

  BookState copyWith({
    BookStatus Function()? status,
    BalanceStatus Function()? balanceStatus,
    List<Spending> Function()? spendings,
    BookSpendingsFilter Function()? filter,
    Spending? Function()? lastDeletedSpending,
    DateTime? selectedDay,
    DateTime? focusedDay,
    CalendarFormat? calendarFormat,
  }) {
    return BookState(
      status: status != null ? status() : this.status,
      balanceStatus: balanceStatus != null ? balanceStatus() : this.balanceStatus,
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
        balanceStatus,
        spendings,
        filter,
        lastDeletedSpending,
        selectedDay,
        focusedDay,
        calendarFormat,
      ];
}
