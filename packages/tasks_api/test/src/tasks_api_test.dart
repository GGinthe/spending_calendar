// ignore_for_file: prefer_const_constructors
import 'package:tasks_api/tasks_api.dart';
import 'package:test/test.dart';


class TestTasksApi extends TasksApi {
  TestTasksApi() : super();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  group('TodosApi', () {
    test('can be constructed', () {
      expect(TestTasksApi.new, returnsNormally);
    });
  });
}
