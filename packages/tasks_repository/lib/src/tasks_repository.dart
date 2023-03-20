import 'package:tasks_api/tasks_api.dart';

/// {@template tasks_repository}
/// A repository that handles `task` related requests.
/// {@template}
class TasksRepository {
  /// {@macro tasks_repository}
  const TasksRepository({
    required TasksApi tasksApi,
  }) : _tasksApi = tasksApi;

  final TasksApi _tasksApi;

  /// Provides a [Stream] of all tasks.
  Stream<List<Task>> getTasks() => _tasksApi.getTasks();

  /// Return [Task] in given DateTime.
  List<Task> getDayTasks(DateTime dateTime) => _tasksApi.getDayTasks(dateTime);

  /// Saves a [task].
  /// If a [task] with the same id already exists, it will be replaced.
  Future<void> saveTask(Task task) => _tasksApi.saveTask(task);

  /// Deletes the `task` with the given id.
  /// If no given id exists, [TaskNotFoundException] error is thrown.
  Future<void> deleteTask(String id) => _tasksApi.deepDeleteTask(id);

  /// Deep delete task
  /// Returns the number of deleted tasks.
  Future<int> deepDeleteAll({required bool isDeleted}) =>
      _tasksApi.deepDeleteAll(isDeleted: isDeleted);

  /// Deletes all completed tasks.
  /// Returns the number of deleted tasks.
  Future<int> clearCompleted() => _tasksApi.clearCompleted();

  /// Sets the `isCompleted` state of all tasks to the given value.
  /// Returns the number of updated tasks.
  Future<int> completeAll({required bool isCompleted}) =>
      _tasksApi.completeAll(isCompleted: isCompleted);
}
