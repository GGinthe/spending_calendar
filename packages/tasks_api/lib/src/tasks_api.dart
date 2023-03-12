import 'package:tasks_api/tasks_api.dart';

/// {@template tasks_api}
/// The interface for an API that provides access to a list of tasks.
/// {@endtemplate}
abstract class TasksApi {
  /// {@macro tasks_api}
  const TasksApi();

  /// Provides a [Stream] of all tasks.
  Stream<List<Task>> getTasks();

  /// If a [task] with the same id already exists, it will be replaced.
  Future<void> saveTask(Task task);

  /// Deletes the `task` with the given id.
  /// set isDeleted to true, which can be restore
  /*Future<void> fakeDeleteTask(String id);*/

  /// Deletes the `task` with the given id.
  /// isDeleted must be true
  Future<void> deepDeleteTask(String id);

  /// Deep delete task
  /// Returns the number of deleted tasks.
  Future<int> deepDeleteAll({required bool isDeleted});

  /// Deletes all completed tasks.
  /// Returns the number of deleted tasks.
  Future<int> clearCompleted();

  /// Sets the `isCompleted` state of all tasks to the given value.
  /// Returns the number of updated tasks.
  Future<int> completeAll({required bool isCompleted});
}

/// Error thrown when a [task] with a given id is not found.
class TaskNotFoundException implements Exception {}
