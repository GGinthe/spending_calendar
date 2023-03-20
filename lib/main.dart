import 'package:flutter/widgets.dart';
import 'package:spending_calendar/bootstrap.dart';
import 'package:local_storage_tasks_api/local_storage_tasks_api.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:local_storage_spendings_api/local_storage_spendings_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();
  final instance = await SharedPreferences.getInstance();
  final todosApi = LocalStorageTasksApi(
    plugin: instance,
  );
  final spendingApi = LocalStorageSpendingApi(
    plugin: instance,
  );

  bootstrap(tasksApi: todosApi, spendingApi: spendingApi);
}

//新增未顯示行事曆
// 日期點選未顯示
// 編輯日期未改變
