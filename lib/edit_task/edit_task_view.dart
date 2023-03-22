import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spending_calendar/edit_task/edit_task.dart';
import 'package:tasks_repository/tasks_repository.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class EditTaskPage extends StatelessWidget {
  const EditTaskPage({super.key});

  static Route<void> route({Task? initialTask}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => EditTaskBloc(
          tasksRepository: context.read<TasksRepository>(),
          initialTask: initialTask,
        ),
        child: const EditTaskPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditTaskBloc, EditTaskState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.status == EditTaskStatus.success,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('創建成功')));
        Navigator.of(context).pop();
      },
      child: const EditTaskView(),
    );
  }
}

class EditTaskView extends StatelessWidget {
  const EditTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select((EditTaskBloc bloc) => bloc.state.status);
    final isNewTask = context.select(
      (EditTaskBloc bloc) => bloc.state.isNewTask,
    );
    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final fabBackgroundColor = floatingActionButtonTheme.backgroundColor ?? theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewTask ? '新增行程' : '編輯行程',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '儲存',
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        backgroundColor: status.isLoadingOrSuccess ? fabBackgroundColor.withOpacity(0.5) : fabBackgroundColor,
        onPressed: status.isLoadingOrSuccess
            ? null
            : () => context.read<EditTaskBloc>().add(const EditTaskSubmitted()),
        child:
            status.isLoadingOrSuccess ? const CupertinoActivityIndicator() : const Icon(Icons.check_rounded),
      ),
      body: const CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _TitleField(),
                _DescriptionField(),
                _StartDatePicker(),
                _EndDatePicker(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleField extends StatelessWidget {
  const _TitleField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTaskBloc>().state;
    final hintText = state.initialTask?.title ?? '';
    const maxLength = 25;
    final textLength = state.title.length;

    return Column(
      children: [
        TextFormField(
          key: const Key('editTaskView_title_textFormField'),
          initialValue: state.title,
          decoration: InputDecoration(
            enabled: !state.status.isLoadingOrSuccess,
            labelText: '標題',
            hintText: hintText,
            suffixText: '${textLength.toString()}/${maxLength.toString()}',
            counterText: "",
          ),
          style: const TextStyle(fontSize: 20),
          maxLength: maxLength,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxLength),
            //FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]')),
          ],
          onChanged: (value) {
            context.read<EditTaskBloc>().add(EditTaskTitleChanged(value));
          },
        ),
        if (!state.isTitleFieldCorrect) ...[
          const Text(
            '標題無法空白',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTaskBloc>().state;
    final hintText = state.initialTask?.description ?? '';
    const maxLength = 200;
    final textLength = state.description.length;

    return TextFormField(
      key: const Key('editTaskView_description_textFormField'),
      initialValue: state.description,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '描述',
        hintText: hintText,
        suffixText: '${textLength.toString()}/${maxLength.toString()}',
        counterText: "",
      ),
      style: const TextStyle(fontSize: 20),
      maxLength: maxLength,
      maxLines: 5,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength),
      ],
      onChanged: (value) {
        context.read<EditTaskBloc>().add(EditTaskDescriptionChanged(value));
      },
    );
  }
}

class _StartDatePicker extends StatelessWidget {
  const _StartDatePicker();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTaskBloc>().state;
    final DateTime? startDate = state.startDate;
    final initialStartText =
        startDate == null ? '請選擇日期' : DateFormat('yyyy 年 MM 月 dd 日 – kk 點 mm 分').format(startDate);

    return Column(
      children: [
        TextFormField(
          key: Key(initialStartText),
          initialValue: initialStartText,
          decoration: InputDecoration(
            enabled: !state.status.isLoadingOrSuccess,
            labelText: '開始日期',
          ),
          readOnly: true,
          style: const TextStyle(fontSize: 20),
          onTap: () async {
            DateTime? pickerDate = await showOmniDateTimePicker(
              context: context,
              initialDate: startDate,
            );
            if (context.mounted && pickerDate != null) {
              context.read<EditTaskBloc>().add(EditTaskStartDateChanged(pickerDate));
            }
          },
        ),
        if (!state.isTimeFieldCorrect) ...[
          const Text(
            '請選擇時間',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }
}

class _EndDatePicker extends StatelessWidget {
  const _EndDatePicker();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTaskBloc>().state;
    final endDate = state.endDate;
    final initialEndText =
        endDate == null ? '請選擇日期' : DateFormat('yyyy 年 MM 月 dd 日 – kk 點 mm 分').format(endDate);

    return Column(
      children: [
        TextFormField(
          key: Key(initialEndText),
          initialValue: initialEndText,
          decoration: InputDecoration(
            enabled: !state.status.isLoadingOrSuccess,
            labelText: '結束日期',
          ),
          readOnly: true,
          style: const TextStyle(fontSize: 20),
          onTap: () async {
            DateTime? pickerDate = await showOmniDateTimePicker(
              context: context,
              initialDate: endDate,
            );
            if (context.mounted && pickerDate != null) {
              context.read<EditTaskBloc>().add(EditTaskEndDateChanged(pickerDate));
            }
          },
        ),
        if (!state.isTimeFieldCorrect) ...[
          const Text(
            '請選擇時間',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }
}
