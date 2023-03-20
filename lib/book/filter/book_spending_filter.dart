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

  Iterable<Spending> getDaySpendings(Iterable<Spending> spendings, DateTime dateTime) {
    return spendings.where((spending) => isSameDay(spending.startDate, dateTime));
  }
}
