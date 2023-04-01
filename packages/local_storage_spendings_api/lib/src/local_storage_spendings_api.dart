import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_api/spending_api.dart';

/// {@template local_storage_spending's_api}
/// A Flutter implementation of the [SpendingApi] that uses local storage.
/// {@template}
class LocalStorageSpendingApi extends SpendingApi {
  /// {@macro local_storage_spendings_api}
  LocalStorageSpendingApi({
    required SharedPreferences plugin,
  }) : _plugin = plugin {
    _init();
  }

  final SharedPreferences _plugin;

  final _spendingStreamController = BehaviorSubject<List<Spending>>.seeded(const []);

  /// The key used for storing the spendings locally.
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kSpendingCollectionKey = '__spending_collection_key__';

  String? _getValue(String key) => _plugin.getString(key);

  Future<void> _setValue(String key, String value) => _plugin.setString(key, value);

  /// get json from local storage.
  /// If first time, create an empty json.
  /// Add spending to stream
  void _init() {
    final spendingJson = _getValue(kSpendingCollectionKey);
    if (spendingJson != null) {
      final spending = List<Map<dynamic, dynamic>>.from(
        json.decode(spendingJson) as List,
      ).map((jsonMap) => Spending.fromJson(Map<String, dynamic>.from(jsonMap))).toList();
      _spendingStreamController.add(spending);
    } else {
      _spendingStreamController.add(const []);
    }
  }

  @override
  Stream<List<Spending>> getSpendings() => _spendingStreamController.asBroadcastStream();

  @override
  Future<void> saveSpendings(Spending spending) {
    final spendings = [..._spendingStreamController.value];
    final spendingIndex = spendings.indexWhere((t) => t.id == spending.id);
    if (spendingIndex >= 0) {
      spendings[spendingIndex] = spending;
    } else {
      spendings.add(spending);
    }
    _spendingStreamController.add(spendings);
    return _setValue(kSpendingCollectionKey, json.encode(spendings));
  }

  @override
  Future<void> deepDeleteSpendings(String id) async {
    final spendings = [..._spendingStreamController.value];
    final spendingIndex = spendings.indexWhere((t) => t.id == id);
    if (spendingIndex == -1) {
      throw SpendingNotFoundException();
    } else {
      spendings.removeAt(spendingIndex);
      _spendingStreamController.add(spendings);
      return _setValue(kSpendingCollectionKey, json.encode(spendings));
    }
  }

  @override
  Future<int> deepDeleteAll({required bool isDeleted}) async {
    final spending = [..._spendingStreamController.value];
    final deletedSpendingAmount = spending.where((t) => t.isDeleted).length;
    spending.removeWhere((t) => t.isDeleted);
    _spendingStreamController.add(spending);
    await _setValue(kSpendingCollectionKey, json.encode(spending));
    return deletedSpendingAmount;
  }

  bool _isBetween(DateTime? startTime, DateTime? endTime, DateTime? betweenTime) {
    if (startTime == null || endTime == null || betweenTime == null) {
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
  Future<void> editSpendingDateByTask(
      {required String taskId, required DateTime startTime, required DateTime endTime,}) async {
    final spendings = [..._spendingStreamController.value];
    //final editSpending = [for (var i in spending) i.taskId == TaskId ? i.copyWith(startDate: dateTime) : i];
    final editSpending = [
      for (var spending in spendings)
        if (spending.taskId == taskId && !_isBetween(startTime, endTime, spending.startDate)) ...[
          spending.copyWith(startDate: startTime)
        ] else ...[
          spending
        ]
    ];
    _spendingStreamController.add(editSpending);
    return _setValue(kSpendingCollectionKey, json.encode(editSpending));
  }

  @override
  List<Spending> getSpendingsFromTaskID(String taskId) {
    final spendings = [..._spendingStreamController.value];
    return spendings.where((spending) => spending.taskId == taskId).toList();
  }
}
