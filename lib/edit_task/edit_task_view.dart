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
      listener: (context, state) => Navigator.of(context).pop(),
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

    return TextFormField(
      key: const Key('editTaskView_title_textFormField'),
      initialValue: state.title,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '標題',
        hintText: hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]')),
      ],
      onChanged: (value) {
        context.read<EditTaskBloc>().add(EditTaskTitleChanged(value));
      },
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTaskBloc>().state;
    final hintText = state.initialTask?.description ?? '';

    return TextFormField(
      key: const Key('editTaskView_description_textFormField'),
      initialValue: state.description,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '描述',
        hintText: hintText,
      ),
      maxLength: 300,
      maxLines: 7,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
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
    final startDate = state.initialTask?.startDate;
    final pickerDate = state.startDate;
    DateTime? initialDate;
    if (pickerDate != null) {
      initialDate = pickerDate;
    } else if (startDate != null) {
      initialDate = startDate;
    }
    final initialStartText =
        initialDate == null ? '請選擇日期' : DateFormat('yyyy 年 MM 月 dd 日 – kk 點 mm 分').format(initialDate);

    return TextFormField(
      key: Key(initialStartText),
      initialValue: initialStartText,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '開始日期',
        hintText: 'hintText',
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickerDate = await showOmniDateTimePicker(
          context: context,
          initialDate: initialDate,
        );
        if (context.mounted && pickerDate != null) {
          context.read<EditTaskBloc>().add(EditTaskStartDateChanged(pickerDate));
        }
      },
    );
  }
}

class _EndDatePicker extends StatelessWidget {
  const _EndDatePicker();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTaskBloc>().state;
    final endDate = state.initialTask?.endDate;
    final pickerDate = state.endDate;
    DateTime? initialDate;
    if (pickerDate != null) {
      initialDate = pickerDate;
    } else if (endDate != null) {
      initialDate = endDate;
    }
    final initialEndText =
        initialDate == null ? '請選擇日期' : DateFormat('yyyy 年 MM 月 dd 日 – kk 點 mm 分').format(initialDate);
    return TextFormField(
      key: Key(initialEndText),
      initialValue: initialEndText,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '結束日期',
        hintText: 'hintText',
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickerDate = await showOmniDateTimePicker(
          context: context,
          initialDate: initialDate,
        );
        if (context.mounted && pickerDate != null) {
          context.read<EditTaskBloc>().add(EditTaskEndDateChanged(pickerDate));
        }
      },
    );
  }
}
