// ignore_for_file: lines_longer_than_80_chars

import 'package:spending_api/spending_api.dart';

/// {@template spending_api}
/// The interface for an API that provides access to a list of spending.
/// {@template}
abstract class SpendingApi {
  /// {@macro spending_api}
  const SpendingApi();

  /// Provides a [Stream] of all spendings.
  Stream<List<Spending>> getSpendings();

  /// If a [spending] with the same id already exists, it will be replaced.
  Future<void> saveSpendings(Spending spending);

  /// Return [Spending] in given TaskId.
  List<Spending> getSpendingsFromTaskID(String taskId);

  /// Deletes the `spending` with the given id.
  /// set isDeleted to true, which can be restore
  /*Future<void> fakeDeleteSpending(String id);*/

  /// Deletes the `spending` with the given id.
  /// isDeleted must be true
  Future<void> deepDeleteSpendings(String id);

  /// Deep delete spending
  /// Returns the number of deleted spendings.
  Future<int> deepDeleteAll({required bool isDeleted});

  /// Edit Spending.startDate by taskId
  Future<void> editSpendingDateByTask(
      {required String taskId, required DateTime startTime, required DateTime endTime,});
}

/// Error thrown when a [Spending] with a given id is not found.
class SpendingNotFoundException implements Exception {}
