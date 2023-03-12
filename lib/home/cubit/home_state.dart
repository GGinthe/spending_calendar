part of 'home_cubit.dart';

enum HomeTab { calendar, spending }

class HomeState extends Equatable {
  const HomeState({
    this.tab = HomeTab.calendar,
  });

  final HomeTab tab;

  @override
  List<Object> get props => [tab];
}
