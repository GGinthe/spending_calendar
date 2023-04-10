import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spending_calendar/edit_spending/edit_spending.dart';
import 'package:spending_calendar/icon_select.dart';

class SubjectExpansion extends StatelessWidget {
  const SubjectExpansion({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditSpendingBloc>().state;
    final isExpand = state.isExpand;
    final selectedSubject = state.subject ?? '其他';
    const headerIconSize = 40.0;
    const bodyIconSize = 35.0;
    Widget icon(String text, double iconSize) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkResponse(
          onTap: () {
            context.read<EditSpendingBloc>().add(EditSpendingSubjectChanged(text));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              spendingIcon(text, selectedSubject == text ? Colors.red : Colors.black, iconSize),
              Text(text, style: TextStyle(color: selectedSubject == text ? Colors.red : null)),
            ],
          ),
        ),
      );
    }

    Widget iconRow(List<String> spendingText, double iconSize) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [for (var i in spendingText) icon(i, iconSize)],
      );
    }

    final List<String> headerExpanse = ['餐飲', '交通', '購物', '其他'];
    final List<String> headerIncome = ['薪水', '股票', '回饋', '其他'];
    final List<List<String>> bodyExpanse = [
      [
        '早餐',
        '午餐',
        '晚餐',
        '飲品',
        '點心',
        '禮物',
      ],
      [
        '數位',
        '日用',
        '娛樂',
        '房租',
        '醫療',
        '社交',
      ],
      ['學習', '保險']
    ];
    final List<List<String>> bodyIncome = [
      ['獎金', '租金', '投資', '兼職', '買賣', '發票']
    ];
    List<String> headText = [];
    if (state.spendingType == SpendingType.expenses) {
      headText = headerExpanse;
      if (!headerExpanse.contains(selectedSubject)) {
        headText.add(selectedSubject);
      }
    } else {
      headText = headerIncome;
      if (!headerIncome.contains(selectedSubject)) {
        headText.add(selectedSubject);
      }
    }

    return ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: const EdgeInsets.all(2),
        children: [
          ExpansionPanel(
            canTapOnHeader: false,
            headerBuilder: (context, isExpanded) {
              if (!isExpanded) {
                if (state.spendingType == SpendingType.expenses) {
                  return iconRow(headerExpanse, headerIconSize);
                } else {
                  return iconRow(headerIncome, headerIconSize);
                }
              } else {
                if (state.spendingType == SpendingType.expenses) {
                  return iconRow(headerExpanse, bodyIconSize);
                } else {
                  return iconRow(headerIncome, bodyIconSize);
                }
              }
            },
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (state.spendingType == SpendingType.expenses) ...[
                  for (var text in bodyExpanse) iconRow(text, bodyIconSize),
                ] else ...[
                  for (var text in bodyIncome) iconRow(text, bodyIconSize),
                ]
              ],
            ),
            isExpanded: isExpand,
          ),
        ],
        expansionCallback: (panelIndex, isExpanded) {
          context.read<EditSpendingBloc>().add(const EditSpendingIsExpandChanged());
        });
  }
}
