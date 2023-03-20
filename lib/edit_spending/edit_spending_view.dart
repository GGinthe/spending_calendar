import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spending_calendar/edit_spending/edit_spending.dart';
import 'package:spending_repository/spending_repository.dart';
import 'package:tasks_repository/tasks_repository.dart';

class EditSpendingPage extends StatelessWidget {
  const EditSpendingPage({super.key});

  static Route<void> route({Spending? initialSpending}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => EditSpendingBloc(
          spendingsRepository: context.read<SpendingRepository>(),
          tasksRepository: context.read<TasksRepository>(),
          initialSpending: initialSpending,
        ),
        child: const EditSpendingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditSpendingBloc, EditSpendingState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.status == EditSpendingStatus.success,
      listener: (context, state) => Navigator.of(context).pop(),
      child: const EditSpendingView(),
    );
  }
}

class EditSpendingView extends StatelessWidget {
  const EditSpendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select((EditSpendingBloc bloc) => bloc.state.status);
    final isNewSpending = context.select(
      (EditSpendingBloc bloc) => bloc.state.isNewSpending,
    );
    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final fabBackgroundColor = floatingActionButtonTheme.backgroundColor ?? theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewSpending ? '新增花費' : '編輯花費',
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
            : () => context.read<EditSpendingBloc>().add(const EditSpendingSubmitted()),
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
                _MoneyField(),
                /*_SubjectDropDownButton(),
                SizedBox(height: 10),
                _StartDatePicker(),*/
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: _SubjectDropDownButton(),
                    ),
                    SizedBox(width: 20),
                    Flexible(
                      child: _StartDatePicker(),
                    ),
                  ],
                ),
                _TaskDropDownButton(),
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
    final state = context.watch<EditSpendingBloc>().state;
    final hintText = state.initialSpending?.title ?? '';

    return TextFormField(
      key: const Key('editSpendingView_title_textFormField'),
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
        context.read<EditSpendingBloc>().add(EditSpendingTitleChanged(value));
      },
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditSpendingBloc>().state;
    final hintText = state.initialSpending?.money.toString() ?? '';

    return TextFormField(
      key: const Key('editSpendingView_money_textFormField'),
      initialValue: state.money.toString(),
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '支出',
        hintText: hintText,
      ),
      maxLength: 50,
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
        FilteringTextInputFormatter.digitsOnly,
      ],
      // Only numbers can be entered
      onChanged: (value) {
        context.read<EditSpendingBloc>().add(EditSpendingMoneyChanged(int.parse(value)));
      },
    );
  }
}

class _StartDatePicker extends StatelessWidget {
  const _StartDatePicker();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditSpendingBloc>().state;
    final startDate = state.initialSpending?.startDate;
    final pickerDate = state.startDate;
    DateTime? initialDate;
    if (pickerDate != null) {
      initialDate = pickerDate;
    } else if (startDate != null) {
      initialDate = startDate;
    }
    final initialStartText =
        initialDate == null ? '請選擇日期' : DateFormat('yyyy 年 MM 月 dd 日').format(initialDate);

    return TextFormField(
      key: Key(initialStartText),
      initialValue: initialStartText,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '日期',
        hintText: 'hintText',
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickerDate = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (context.mounted && pickerDate != null) {
          context.read<EditSpendingBloc>().add(EditSpendingStartDateChanged(pickerDate));
        }
      },
    );
  }
}

class _TaskDropDownButton extends StatelessWidget {
  const _TaskDropDownButton();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditSpendingBloc>().state;
    context.read<EditSpendingBloc>().add(EditSpendingTaskChanged(state.initialSpending?.taskId));
    final pickerTask = state.taskId == '' ? null : state.taskId;
    final taskList = [
      ...[for (var task in state.tasks) task.toString()]
    ];

    return DropdownButtonFormField<String>(
      key: const Key('editSpendingView_task_dropdownButton'),
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '行程花費',
        hintText: 'hintText',
      ),
      items: taskList.isNotEmpty
          ? taskList.map((title) {
              return DropdownMenuItem(value: title, child: Text(title));
            }).toList()
          : null,
      value: pickerTask,
      hint: const Text('此日無行程'),
      onChanged: (value) {
        context.read<EditSpendingBloc>().add(EditSpendingTaskChanged(value ?? ''));
      },
    );
  }
}

class _SubjectDropDownButton extends StatelessWidget {
  const _SubjectDropDownButton();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditSpendingBloc>().state;
    final hintText = state.initialSpending?.subject ?? '其他';
    final itemList = ['其他', '1', '2', '3'];
    return DropdownButtonFormField<String>(
      key: const Key('editSpendingView_subject_dropdownButton'),
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '類別',
        hintText: 'hintText',
      ),
      items: itemList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      value: hintText,
      hint: const Text('類別'),
      onChanged: (value) {
        context.read<EditSpendingBloc>().add(EditSpendingSubjectChanged(value ?? ''));
      },
    );
  }
}
