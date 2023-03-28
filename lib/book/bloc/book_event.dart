part of 'book_bloc.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object> get props => [];
}

/// Startup event.
/// In response, the bloc subscribes to the stream of spending from the SpendingRepository.
class BookSubscriptionRequested extends BookEvent {
  const BookSubscriptionRequested();
}

/// This deletes a Spending.
class BookSpendingDeleted extends BookEvent {
  const BookSpendingDeleted(this.spending);

  final Spending spending;

  @override
  List<Object> get props => [spending];
}

/// This undoes a spending deletion, e.g. an accidental deletion.
class BookUndoDeletionRequested extends BookEvent {
  const BookUndoDeletionRequested();
}

/// This takes a BookSpendingFilter as an argument and changes the view
/// by applying a filter.
class BookSpendingFilterChanged extends BookEvent {
  const BookSpendingFilterChanged(this.filter);

  final BookSpendingsFilter filter;

  @override
  List<Object> get props => [filter];
}

class CalendarDaySelected extends BookEvent {
  const CalendarDaySelected({required this.selectedDay, required this.focusedDay});

  final DateTime selectedDay;
  final DateTime focusedDay;

  @override
  List<Object> get props => [selectedDay, focusedDay];
}

class CalendarFormatChanged extends BookEvent {
  const CalendarFormatChanged(this.calendarFormat);

  final CalendarFormat calendarFormat;

  @override
  List<Object> get props => [calendarFormat];
}

class CalendarBalanceChanged extends BookEvent {
  const CalendarBalanceChanged();

  @override
  List<Object> get props => [];
}
