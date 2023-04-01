import 'package:spending_api/spending_api.dart';

/// {@template spending_repository}
/// A repository that handles `spending` related requests.
/// {@template}
class SpendingRepository {
  /// {@macro spending_repository}
  const SpendingRepository({
    required SpendingApi spendingApi,
  }) : _spendingApi = spendingApi;

  final SpendingApi _spendingApi;

  /// Return [Spending] in given TaskId.
  List<Spending> getSpendingsFromTaskID(String taskId) => _spendingApi.getSpendingsFromTaskID(taskId);

  /// Provides a [Stream] of all spending.
  Stream<List<Spending>> getSpendings() => _spendingApi.getSpendings();

  /// Saves a [spending].
  /// If a [spending] with the same id already exists, it will be replaced.
  Future<void> saveSpendings(Spending spending) => _spendingApi.saveSpendings(spending);

  /// Deletes the `spending` with the given id.
  /// If no given id exists, [SpendingNotFoundException] error is thrown.
  Future<void> deleteSpendings(String id) => _spendingApi.deepDeleteSpendings(id);

  /// Deep delete spending
  /// Returns the number of deleted spending.
  Future<int> deepDeleteAll({required bool isDeleted}) => _spendingApi.deepDeleteAll(isDeleted: isDeleted);

  /// Edit Spending.startDate by taskId
  Future<void> editSpendingDateByTask(
          {required String taskId, required DateTime startTime, required DateTime endTime,}) =>
      _spendingApi.editSpendingDateByTask(taskId: taskId, startTime: startTime, endTime: endTime);
}
