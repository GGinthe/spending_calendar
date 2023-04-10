import 'package:flutter/widgets.dart';
import 'package:spending_calendar/bootstrap.dart';
import 'package:local_storage_tasks_api/local_storage_tasks_api.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:local_storage_spendings_api/local_storage_spendings_api.dart';
import 'notification/notification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();
  final instance = await SharedPreferences.getInstance();
  await notification.init();

  final todosApi = LocalStorageTasksApi(
    plugin: instance,
  );
  final spendingApi = LocalStorageSpendingApi(
    plugin: instance,
  );

  bootstrap(tasksApi: todosApi, spendingApi: spendingApi);
}
