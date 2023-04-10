import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spending_calendar/edit_task/edit_task.dart';
import 'package:spending_repository/spending_repository.dart';
import 'package:tasks_repository/tasks_repository.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:spending_calendar/icon_select.dart';
import 'package:spending_calendar/book/widgets/spending_list_tile.dart';

class EditTaskPage extends StatelessWidget {
  const EditTaskPage({super.key});

  static Route<void> route({Task? initialTask}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => EditTaskBloc(
          spendingsRepository: context.read<SpendingRepository>(),
          tasksRepository: context.read<TasksRepository>(),
          initialTask: initialTask,
        )..add(const EditTaskSpendingInit()),
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
                _SubjectButton(),
                _StartDatePicker(),
                _EndDatePicker(),
                SizedBox(height: 5),
                _NotificationPicker(),
                SizedBox(height: 5),
                _SpendingListView(),
                SizedBox(height: 40)
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
    const maxLength = 100;
    final textLength = state.description.length;

    return TextFormField(
      key: const Key('editTaskView_description_textFormField'),
      initialValue: state.description,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '備註',
        hintText: hintText,
        suffixText: '${textLength.toString()}/${maxLength.toString()}',
        counterText: "",
      ),
      style: const TextStyle(fontSize: 20),
      maxLength: maxLength,
      maxLines: 2,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength),
      ],
      onChanged: (value) {
        context.read<EditTaskBloc>().add(EditTaskDescriptionChanged(value));
      },
    );
  }
}

class _SubjectButton extends StatelessWidget {
  const _SubjectButton();

  @override
  Widget build(BuildContext context) {
    final selected = context.select((EditTaskBloc bloc) => bloc.state.subject);

    Widget icon(String text) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkResponse(
          onTap: () {
            context.read<EditTaskBloc>().add(EditTaskSubjectChanged(text));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              editTaskIcon(text, selected == text),
              Text(text, style: TextStyle(color: selected == text ? Colors.red : null)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        icon("工作"),
        icon("活動"),
        icon("提醒"),
        icon("其他"),
      ],
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
          style: const TextStyle(fontSize: 17),
          onTap: () async {
            DateTime? pickerDate = await showOmniDateTimePicker(
              context: context,
              minutesInterval: 5,
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
          style: const TextStyle(fontSize: 17),
          onTap: () async {
            DateTime? pickerDate = await showOmniDateTimePicker(
              context: context,
              minutesInterval: 5,
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

class _NotificationPicker extends StatelessWidget {
  const _NotificationPicker();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTaskBloc>().state;
    final isHourCheck = state.isHourCheck;
    final isDayCheck = state.isDayCheck;
    final isWeekCheck = state.isWeekCheck;
    final isBeginCheck = state.isBeginCheck;
    final isCheckExpand = state.isCheckExpand;
    final pickerType = state.notificationType;
    final pickerText = state.notificationText.toString();
    String notificationText = '';
    if (isBeginCheck) {
      notificationText += '開始時';
    }
    if (isHourCheck) {
      if (isBeginCheck) {
        notificationText += ', ';
      }
      notificationText += '1 小時前';
    }
    if (isDayCheck) {
      if (isHourCheck || isBeginCheck) {
        notificationText += ', ';
      }
      notificationText += '1 天前';
    }
    if (isWeekCheck) {
      if (isHourCheck || isDayCheck || isBeginCheck) {
        notificationText += ', ';
      }
      notificationText += '1 週前';
    }

    if (pickerText != '0' && pickerText != '') {
      if (isHourCheck || isDayCheck || isWeekCheck || isBeginCheck) {
        notificationText += ', ';
      }
      notificationText += '$pickerText  $pickerType';
    }
    if(notificationText.length > 26 ){
      notificationText = '${notificationText.substring(0, 25)}...';
    }

    return ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: const EdgeInsets.all(2),
        children: [
          ExpansionPanel(
            canTapOnHeader: false,
            headerBuilder: (context, isExpanded) {
              if (!isExpanded) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (notificationText.length < 20) const Icon(Icons.notifications, size: 30),
                    if (notificationText.length < 15)
                      const Text('提醒',
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18)),
                    Text(notificationText, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                );
              } else {
                return Container(
                    padding: const EdgeInsets.only(top: 5, left: 15),
                    child: const Text(
                      '提醒設定',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ));
              }
            },
            body: ListView(
              shrinkWrap: true,
              children: ListTile.divideTiles(context: context, tiles: [
                CheckboxListTile(
                  title: const Text('活動開始時'),
                  value: isBeginCheck,
                  onChanged: (bool? value) {
                    context.read<EditTaskBloc>().add(const EditTaskIsCheckChanged(4));
                  },
                  secondary: const Icon(Icons.notifications),
                ),
                CheckboxListTile(
                  title: const Text('一小時前'),
                  value: isHourCheck,
                  onChanged: (bool? value) {
                    context.read<EditTaskBloc>().add(const EditTaskIsCheckChanged(0));
                  },
                  secondary: const Icon(Icons.notifications),
                ),
                CheckboxListTile(
                  title: const Text('一天前'),
                  value: isDayCheck,
                  onChanged: (bool? value) {
                    context.read<EditTaskBloc>().add(const EditTaskIsCheckChanged(1));
                  },
                  secondary: const Icon(Icons.notifications),
                ),
                CheckboxListTile(
                  title: const Text('一週前'),
                  value: isWeekCheck,
                  onChanged: (bool? value) {
                    context.read<EditTaskBloc>().add(const EditTaskIsCheckChanged(2));
                  },
                  secondary: const Icon(Icons.notifications),
                ),
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: 0),
                  title: SizedBox(
                    width: 80,
                    child: TextFormField(
                      key: const Key('editTextView_notification_textFormField'),
                      initialValue: pickerText,
                      decoration: InputDecoration(
                        enabled: !state.status.isLoadingOrSuccess,
                        counterText: "",
                      ),
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2),
                        FilteringTextInputFormatter.digitsOnly,
                        FilteringTextInputFormatter.deny(RegExp('^0+'))
                      ],
                      onChanged: (value) {
                        context
                            .read<EditTaskBloc>()
                            .add(EditTaskNotificationTextChanged(int.tryParse(value) ?? 0));
                      },
                    ),
                  ),
                  trailing: SizedBox(
                    width: 200,
                    child: DropdownButtonFormField2<String>(
                      key: const Key('editSpendingView_task_dropdownButton'),
                      decoration: InputDecoration(
                        enabled: !state.status.isLoadingOrSuccess,
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.arrow_drop_down,
                        ),
                      ),
                      items: ['分前', '小時前', '天前', '週前', '月前'].map((x) {
                        return DropdownMenuItem(
                            value: x,
                            child: Text(
                              x,
                              style: const TextStyle(fontSize: 14),
                            ));
                      }).toList(),
                      value: pickerType,
                      onChanged: (value) {
                        context.read<EditTaskBloc>().add(EditTaskNotificationTypeChanged(value ?? '分前'));
                      },
                    ),
                  ),
                )
              ]).toList(),
            ),
            isExpanded: isCheckExpand,
          ),
        ],
        expansionCallback: (panelIndex, isExpanded) {
          context.read<EditTaskBloc>().add(const EditTaskIsCheckChanged(3));
        });
  }
}

class _SpendingListView extends StatelessWidget {
  const _SpendingListView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTaskBloc>().state;
    final spendings = state.spendings;

    if (spendings.isEmpty) {
      return const SizedBox();
    }

    final isExpand = state.isExpand;
    final totalMoney = [for (var spending in spendings) spending.money].fold<int>(0, (a, b) => a + b);
    final isIncome = totalMoney > 0 ? true : false;
    Color textColor = Colors.green;
    if (isIncome) {
      textColor = Colors.green;
    } else {
      textColor = Colors.red;
    }
    return ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: const EdgeInsets.all(2),
        children: [
          ExpansionPanel(
            canTapOnHeader: false,
            headerBuilder: (context, isExpanded) {
              if (!isExpanded) {
                return ListTile(
                  title: const Text(
                    '收支',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  dense: true,
                  visualDensity: const VisualDensity(vertical: 0),
                  leading: spendingIcon('其他', textColor, 30),
                  trailing: Text(
                    NumberFormat("#,###", "en_US").format(totalMoney),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              } else {
                return Container(
                    padding: const EdgeInsets.only(top: 5, left: 15),
                    child: const Text(
                      '收支明細',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ));
              }
            },
            body: ListView(
              shrinkWrap: true,
              children: ListTile.divideTiles(context: context, tiles: [
                for (final spending in spendings)
                  SpendingListTile(
                    spending: spending,
                  ),
              ]).toList(),
            ),
            isExpanded: isExpand,
          ),
        ],
        expansionCallback: (panelIndex, isExpanded) {
          context.read<EditTaskBloc>().add(const EditTaskIsExpandChanged());
        });
  }
}
