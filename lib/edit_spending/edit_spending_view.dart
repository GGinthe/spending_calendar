import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
        )..add(const EditSpendingTaskInit()),
        child: const EditSpendingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditSpendingBloc, EditSpendingState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.status == EditSpendingStatus.success,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('創建成功')));
        Navigator.of(context).pop();
      },
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
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: _MoneyField(),
                    ),
                    Expanded(
                      flex: 1,
                      child: _SpendingTypeButton(),
                    ),
                  ],
                ),
                _MoneyValidate(),
                SubjectExpansion(),
                _StartDatePicker(),
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
    const maxLength = 25;
    final textLength = state.title.length;
    return Column(
      children: [
        TextFormField(
          key: const Key('editSpendingView_title_textFormField'),
          initialValue: state.title,
          decoration: InputDecoration(
            enabled: !state.status.isLoadingOrSuccess,
            labelText: '備註',
            hintText: hintText,
            suffixText: '${textLength.toString()}/${maxLength.toString()}',
            counterText: "",
          ),
          maxLength: maxLength,
          style: const TextStyle(fontSize: 20),
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxLength),
            //FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]')),
          ],
          onChanged: (value) {
            context.read<EditSpendingBloc>().add(EditSpendingTitleChanged(value));
          },
        ),
      ],
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditSpendingBloc>().state;
    final hintText = state.initialSpending?.money.toString() ?? '';
    const maxLength = 10;
    String labelText = '支出';
    if (state.spendingType == SpendingType.income) {
      labelText = '收入';
    } else {
      labelText = '支出';
    }

    return TextFormField(
      key: const Key('editSpendingView_money_textFormField'),
      initialValue: state.money.toString(),
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: labelText,
        hintText: hintText,
        counterText: "",
      ),
      maxLength: maxLength,
      style: const TextStyle(fontSize: 20),
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength),
        FilteringTextInputFormatter.digitsOnly,
        FilteringTextInputFormatter.deny(RegExp('^0+'))
      ],
      // Only numbers can be entered
      onChanged: (value) {
        context.read<EditSpendingBloc>().add(EditSpendingMoneyChanged(int.tryParse(value) ?? 0));
      },
    );
  }
}

class _MoneyValidate extends StatelessWidget {
  const _MoneyValidate();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditSpendingBloc>().state;
    if (!state.isMoneyFieldCorrect) {
      return const Text('花費無法為零', style: TextStyle(color: Colors.red), textAlign: TextAlign.center);
    } else {
      return const SizedBox(height: 15);
    }
  }
}

class _SpendingTypeButton extends StatelessWidget {
  const _SpendingTypeButton();

  @override
  Widget build(BuildContext context) {
    final spendingType = context.select((EditSpendingBloc bloc) => bloc.state.spendingType);
    String buttonText = '收入';
    if (spendingType == SpendingType.income) {
      buttonText = '支出';
    } else if (spendingType == SpendingType.expenses) {
      buttonText = '收入';
    }

    return ElevatedButton(
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(10) //content padding inside button
            ),
        onPressed: () {
          context.read<EditSpendingBloc>().add(const EditSpendingTypeChanged());
        },
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 17),
        ));
  }
}

class _StartDatePicker extends StatelessWidget {
  const _StartDatePicker();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditSpendingBloc>().state;
    final startDate = state.startDate;
    final initialStartText = startDate == null ? '請選擇日期' : DateFormat('yyyy 年 MM 月 dd 日').format(startDate);

    return Column(
      children: [
        TextFormField(
          key: Key(initialStartText),
          initialValue: initialStartText,
          decoration: InputDecoration(
            enabled: !state.status.isLoadingOrSuccess,
            labelText: '日期',
            contentPadding: const EdgeInsets.symmetric(vertical: 15.5),
          ),
          readOnly: true,
          style: const TextStyle(fontSize: 20),
          onTap: () async {
            DateTime? pickerDate = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (context.mounted && pickerDate != null) {
              context.read<EditSpendingBloc>().add(EditSpendingStartDateChanged(pickerDate));
            }
          },
        ),
        if (!state.isTimeFieldCorrect) ...[
          const Text(
            '請選擇日期',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }
}

class _TaskDropDownButton extends StatelessWidget {
  const _TaskDropDownButton();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditSpendingBloc>().state;
    var pickerTask = state.selectedTaskId == '' ? null : state.selectedTaskId;
    final taskList = state.tasks;
    final taskIdList = [for (var i in taskList) i.id];

    if (!taskIdList.contains(pickerTask)) {
      pickerTask = null;
    }
    return DropdownButtonFormField2<String>(
      key: const Key('editSpendingView_task_dropdownButton'),
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '行程花費',
        labelStyle: const TextStyle(fontSize: 20),
        //contentPadding: const EdgeInsets.only(top: 15, bottom:15),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 30,
      ),
      buttonStyleData: const ButtonStyleData(
        height: 30,
      ),
      dropdownStyleData: const DropdownStyleData(
        maxHeight: 250,
      ),
      items: taskList.isNotEmpty
          ? taskList.map((task) {
              return DropdownMenuItem(
                  value: task.id,
                  child: Text(
                    task.title,
                    style: const TextStyle(fontSize: 20),
                  ));
            }).toList()
          : null,
      value: pickerTask,
      hint: const Text(
        '請選擇行程',
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.right,
      ),
      disabledHint: const Text('此日無行程', style: TextStyle(fontSize: 20)),
      onChanged: (value) {
        context.read<EditSpendingBloc>().add(EditSpendingTaskChanged(value ?? ''));
      },
    );
  }
}
