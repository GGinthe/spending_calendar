// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' show DateUtils;
import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasks_api/tasks_api.dart';

/// {@template local_storage_tasks_api}
/// A Flutter implementation of the [TasksApi] that uses local storage.
/// {@template}
class LocalStorageTasksApi extends TasksApi {
  /// {@macro local_storage_tasks_api}
  LocalStorageTasksApi({
    required SharedPreferences plugin,
  }) : _plugin = plugin {
    _init();
  }

  final SharedPreferences _plugin;

  final _taskStreamController = BehaviorSubject<List<Task>>.seeded(const []);

  /// The key used for storing the tasks locally.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kTasksCollectionKey = '__tasks_collection_key__';

  String? _getValue(String key) => _plugin.getString(key);

  Future<void> _setValue(String key, String value) => _plugin.setString(key, value);

  /// get json from local storage.
  /// If first time, create an empty json.
  /// Add task to stream
  void _init() {
    final tasksJson = _getValue(kTasksCollectionKey);
    if (tasksJson != null) {
      final tasks = List<Map<dynamic, dynamic>>.from(
        json.decode(tasksJson) as List,
      ).map((jsonMap) => Task.fromJson(Map<String, dynamic>.from(jsonMap))).toList();
      _taskStreamController.add(tasks);
    } else {
      _taskStreamController.add(const []);
    }
  }

  @override
  Stream<List<Task>> getTasks() => _taskStreamController.asBroadcastStream();

  @override
  Future<void> saveTask(Task task) {
    final tasks = [..._taskStreamController.value];
    final taskIndex = tasks.indexWhere((t) => t.id == task.id);
    if (taskIndex >= 0) {
      tasks[taskIndex] = task;
    } else {
      tasks.add(task);
    }
    _taskStreamController.add(tasks);
    return _setValue(kTasksCollectionKey, json.encode(tasks));
  }

  @override
  Future<void> deepDeleteTask(String id) async {
    final tasks = [..._taskStreamController.value];
    final taskIndex = tasks.indexWhere((t) => t.id == id);
    if (taskIndex == -1) {
      throw TaskNotFoundException();
    } else {
      tasks.removeAt(taskIndex);
      _taskStreamController.add(tasks);
      return _setValue(kTasksCollectionKey, json.encode(tasks));
    }
  }

  @override
  Future<int> deepDeleteAll({required bool isDeleted}) async {
    final tasks = [..._taskStreamController.value];
    final deletedTasksAmount = tasks.where((t) => t.isDeleted).length;
    tasks.removeWhere((t) => t.isDeleted);
    _taskStreamController.add(tasks);
    await _setValue(kTasksCollectionKey, json.encode(tasks));
    return deletedTasksAmount;
  }

  @override
  Future<int> clearCompleted() async {
    final tasks = [..._taskStreamController.value];
    final completedTasksAmount = tasks.where((t) => t.isCompleted).length;
    tasks.removeWhere((t) => t.isCompleted);
    _taskStreamController.add(tasks);
    await _setValue(kTasksCollectionKey, json.encode(tasks));
    return completedTasksAmount;
  }

  @override
  Future<int> completeAll({required bool isCompleted}) async {
    final tasks = [..._taskStreamController.value];
    final changedTasksAmount = tasks.where((t) => t.isCompleted != isCompleted).length;
    final newTasks = [for (final task in tasks) task.copyWith(isCompleted: isCompleted)];
    _taskStreamController.add(newTasks);
    await _setValue(kTasksCollectionKey, json.encode(newTasks));
    return changedTasksAmount;
  }

  bool _isBetween(DateTime? startTime, DateTime? endTime, DateTime betweenTime) {
    if (startTime == null || endTime == null) {
      return false;
    }
    if (startTime.isBefore(betweenTime) && endTime.isAfter(betweenTime)) {
      return true;
    } else if (DateUtils.isSameDay(startTime, betweenTime) || DateUtils.isSameDay(endTime, betweenTime)) {
      return true;
    }
    return false;
  }

  @override
  List<Task> getDayTasks(DateTime dateTime) {
    final tasks = [..._taskStreamController.value];
    return tasks.where((task) => _isBetween(task.startDate, task.endDate, dateTime)).toList();
  }

  @override
  Task? getTaskFromID(String? taskId) {
    final tasks = [..._taskStreamController.value];
    if (taskId == null || taskId == '') {
      return null;
    }
    return tasks.firstWhere((task) => task.id == taskId);
  }

  @override
  Future<void> addNotifications(Task task, List<Duration> notificationsTime, List<int> notificationsId) {
    final tasks = [..._taskStreamController.value];
    final taskIndex = tasks.indexWhere((t) => t.id == task.id);
    final newTasks = task.copyWith(notificationsDuration: notificationsTime, notificationsId: notificationsId);
    if (taskIndex >= 0) {
      tasks[taskIndex] = newTasks;
    } else {
      tasks.add(newTasks);
    }
    _taskStreamController.add(tasks);
    return _setValue(kTasksCollectionKey, json.encode(tasks));
  }
}
