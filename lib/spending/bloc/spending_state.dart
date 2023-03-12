part of 'spending_bloc.dart';

enum SpendingStatus { initial, loading, success, failure }

class SpendingState extends Equatable {
  const SpendingState({
    this.status = SpendingStatus.initial,
    this.completedTasks = 0,
    this.activeTasks = 0,
  });

  final SpendingStatus status;
  final int completedTasks;
  final int activeTasks;

  @override
  List<Object> get props => [status, completedTasks, activeTasks];

  SpendingState copyWith({
    SpendingStatus? status,
    int? completedTasks,
    int? activeTasks,
  }) {
    return SpendingState(
      status: status ?? this.status,
      completedTasks: completedTasks ?? this.completedTasks,
      activeTasks: activeTasks ?? this.activeTasks,
    );
  }
}
