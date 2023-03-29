import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spending_calendar/book/book.dart';
import 'package:spending_repository/spending_repository.dart';
import 'package:table_calendar/table_calendar.dart';

part 'book_event.dart';

part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  BookBloc({
    required SpendingRepository spendingRepository,
  })  : _spendingRepository = spendingRepository,
        super(const BookState()) {
    on<BookSubscriptionRequested>(_onSubscriptionRequested);
    on<BookSpendingDeleted>(_onSpendingDeleted);
    on<BookUndoDeletionRequested>(_onUndoDeletionRequested);
    on<BookSpendingFilterChanged>(_onFilterChanged);
    on<CalendarDaySelected>(_onCalendarDaySelected);
    on<CalendarFormatChanged>(_onCalendarFormatChanged);
    on<CalendarBalanceChanged>(_onBalanceFormatChanged);
  }

  final SpendingRepository _spendingRepository;

  Future<void> _onSubscriptionRequested(
    BookSubscriptionRequested event,
    Emitter<BookState> emit,
  ) async {
    emit(state.copyWith(status: () => BookStatus.loading));

    await emit.forEach<List<Spending>>(
      _spendingRepository.getSpendings(),
      onData: (spending) => state.copyWith(
        status: () => BookStatus.success,
        spendings: () => spending,
      ),
      onError: (_, __) => state.copyWith(
        status: () => BookStatus.failure,
      ),
    );
  }

  Future<void> _onSpendingDeleted(
    BookSpendingDeleted event,
    Emitter<BookState> emit,
  ) async {
    emit(state.copyWith(lastDeletedSpending: () => event.spending));
    await _spendingRepository.deleteSpendings(event.spending.id);
  }

  Future<void> _onUndoDeletionRequested(
    BookUndoDeletionRequested event,
    Emitter<BookState> emit,
  ) async {
    assert(
      state.lastDeletedSpending != null,
      'Last deleted spending can not be null.',
    );

    final spending = state.lastDeletedSpending!;
    emit(state.copyWith(lastDeletedSpending: () => null));
    await _spendingRepository.saveSpendings(spending);
  }

  void _onFilterChanged(
    BookSpendingFilterChanged event,
    Emitter<BookState> emit,
  ) {
    emit(state.copyWith(filter: () => event.filter));
  }

  void _onCalendarDaySelected(
    CalendarDaySelected event,
    Emitter<BookState> emit,
  ) {
    emit(state.copyWith(selectedDay: event.selectedDay, focusedDay: event.focusedDay));
  }

  void _onCalendarFormatChanged(
    CalendarFormatChanged event,
    Emitter<BookState> emit,
  ) {
    emit(state.copyWith(calendarFormat: event.calendarFormat));
  }

  void _onBalanceFormatChanged(
    CalendarBalanceChanged event,
    Emitter<BookState> emit,
  ) {
    if (state.balanceStatus == BalanceStatus.total) {
      emit(state.copyWith(balanceStatus: () => BalanceStatus.separate));
    } else {
      emit(state.copyWith(balanceStatus: () => BalanceStatus.total));
    }
  }
}
