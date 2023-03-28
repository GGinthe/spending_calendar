import 'package:table_calendar/table_calendar.dart';
import 'package:spending_repository/spending_repository.dart';

enum BookSpendingsFilter { all, deleted, unDeleted }

extension BookSpendingsFilterX on BookSpendingsFilter {
  bool apply(Spending spending) {
    switch (this) {
      case BookSpendingsFilter.all:
        return true;
      case BookSpendingsFilter.deleted:
        return spending.isDeleted;
      case BookSpendingsFilter.unDeleted:
        return !spending.isDeleted;
    }
  }

  bool isDay(Spending spending, DateTime dateTime) {
    return isSameDay(spending.startDate, dateTime);
  }

  Iterable<Spending> applyAll(Iterable<Spending> spendings) {
    return spendings.where(apply);
  }

  /// Return Spendings of given day
  Iterable<Spending> getDaySpendings(Iterable<Spending> spendings, DateTime dateTime) {
    return spendings.where((spending) => isSameDay(spending.startDate, dateTime));
  }

  List<int> getDayTotal(Iterable<Spending> spendings, DateTime dateTime) {
    final daySpending = spendings.where((spending) => isSameDay(spending.startDate, dateTime));
    int totalIncome = 0;
    int totalExpense = 0;
    for (var spending in daySpending) {
      if (spending.money > 0) {
        totalIncome += spending.money;
      } else {
        totalExpense += spending.money;
      }
    }
    return [totalIncome, totalExpense];
  }

  /// Return total money of given week
  List<int> getWeekTotal(Iterable<Spending> spendings, DateTime dateTime) {
    int daysOfWeek = dateTime.weekday == 7 ? 0 : dateTime.weekday;
    DateTime firstDay = DateTime(dateTime.year, dateTime.month, dateTime.day - daysOfWeek);
    int totalIncome = 0;
    int totalExpense = 0;
    for (var i = 0; i < DateTime.daysPerWeek; i++) {
      DateTime searchDate = firstDay.add(Duration(days: i));
      Iterable<Spending> daySpending = getDaySpendings(spendings, searchDate);
      for (var spending in daySpending) {
        if (spending.money > 0) {
          totalIncome += spending.money;
        } else {
          totalExpense += spending.money;
        }
      }
    }
    return [totalIncome, totalExpense];
  }

  /// Return total money of given month
  List<int> getMonthTotal(Iterable<Spending> spendings, DateTime dateTime) {
    final month = dateTime.month;
    final daySpending = spendings.where((spending) => (spending.startDate?.month ?? 0) == month);
    int totalIncome = 0;
    int totalExpense = 0;
    for (var spending in daySpending) {
      if (spending.money > 0) {
        totalIncome += spending.money;
      } else {
        totalExpense += spending.money;
      }
    }
    return [totalIncome, totalExpense];
  }
}
