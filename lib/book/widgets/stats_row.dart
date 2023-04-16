import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spending_calendar/book/book.dart';
import 'package:table_calendar/table_calendar.dart';

class MoneyStatsRow extends StatelessWidget {
  const MoneyStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BookBloc>().state;

    List<int> getDayTotal(DateTime day) {
      return state.getDayTotal(day);
    }

    List<int> getWeekTotal(DateTime day) {
      return state.getWeekTotal(day);
    }

    List<int> getMonthTotal(DateTime day) {
      return state.getMonthTotal(day);
    }

    final selectedDay = state.selectedDay;
    final now = DateTime(2023, 4);
    int calendarIncome = 0;
    int calendarExpense = 0;
    int calendarBalance = 0;
    int weekExpense = 0;
    int weekIncome = 0;
    int monthExpense = 0;
    int monthIncome = 0;
    String incomeText = '月收入';
    String expenseText = '月支出';
    String balanceText = '月收支';
    final dayTotal = getDayTotal(selectedDay ?? now);
    final dayIncome = dayTotal.first;
    final dayExpense = dayTotal.last * -1;
    final dayBalance = dayTotal.first + dayTotal.last;

    if (state.balanceStatus == BalanceStatus.income || state.balanceStatus == BalanceStatus.expanse) {
      final monthTotal = getMonthTotal(selectedDay ?? now);
      monthIncome = monthTotal.first;
      monthExpense = monthTotal.last * -1;
      final weekTotal = getWeekTotal(selectedDay ?? now);
      weekIncome = weekTotal.first;
      weekExpense = weekTotal.last * -1;
    } else {
      if (state.calendarFormat == CalendarFormat.month) {
        final total = getMonthTotal(selectedDay ?? now);
        calendarIncome = total.first;
        calendarExpense = total.last * -1;
        calendarBalance = total.first + total.last;
        incomeText = '月收入';
        expenseText = '月支出';
        balanceText = '月收支';
      }
      if (state.calendarFormat == CalendarFormat.week) {
        final total = getWeekTotal(selectedDay ?? now);
        calendarIncome = total.first;
        calendarExpense = total.last * -1;
        calendarBalance = total.first + total.last;
        incomeText = '週收入';
        expenseText = '週支出';
        balanceText = '週收支';
      }
    }

    return GestureDetector(
      onTap: () {
        if (state.balanceStatus == BalanceStatus.total) {
          context.read<BookBloc>().add(const CalendarBalanceChanged(BalanceStatus.separate));
        } else if (state.balanceStatus == BalanceStatus.separate) {
          context.read<BookBloc>().add(const CalendarBalanceChanged(BalanceStatus.total));
        } else if (state.balanceStatus == BalanceStatus.expanse) {
          context.read<BookBloc>().add(const CalendarBalanceChanged(BalanceStatus.income));
        } else if (state.balanceStatus == BalanceStatus.income) {
          context.read<BookBloc>().add(const CalendarBalanceChanged(BalanceStatus.expanse));
        }
      },
      onLongPress: () {
        if (state.balanceStatus == BalanceStatus.total || state.balanceStatus == BalanceStatus.separate) {
          context.read<BookBloc>().add(const CalendarBalanceChanged(BalanceStatus.expanse));
        } else {
          context.read<BookBloc>().add(const CalendarBalanceChanged(BalanceStatus.separate));
        }
      },
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          border: Border.symmetric(horizontal: BorderSide()),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.balanceStatus == BalanceStatus.total)
              ...totalRow(calendarBalance, dayBalance, balanceText)
            else if (state.balanceStatus == BalanceStatus.separate)
              ...separateRow(calendarIncome, calendarExpense, dayIncome, dayExpense, incomeText, expenseText)
            else if (state.balanceStatus == BalanceStatus.expanse)
              ...expanseRow(monthExpense, weekExpense, dayExpense)
            else if (state.balanceStatus == BalanceStatus.income)
              ...incomeRow(monthIncome, weekIncome, dayExpense)
          ],
        ),
      ),
    );
  }
}

List<Widget> incomeRow(int monthIncome, int weekIncome, int dayIncome) {
  const fontSize = 11.0;
  return [
    Expanded(
      child: Container(
        color: const Color(0xC52DFF50),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                '月收入',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: moneyFormatText(monthIncome),
            ),
          ],
        ),
      ),
    ),
    const VerticalDivider(
      width: 1,
      thickness: 1,
      indent: 20,
      endIndent: 0,
    ),
    Expanded(
      child: Container(
        color: const Color(0xC52DFF50),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                '週收入',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: moneyFormatText(weekIncome),
            ),
          ],
        ),
      ),
    ),
    const VerticalDivider(
      width: 1,
      thickness: 1,
      indent: 20,
      endIndent: 0,
    ),
    Expanded(
      child: Container(
        color: const Color(0xC52DFF50),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                '日收入',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: moneyFormatText(dayIncome),
            ),
          ],
        ),
      ),
    ),
  ];
}

List<Widget> expanseRow(int monthExpense, int weekExpense, int dayExpense) {
  const fontSize = 11.0;
  return [
    Expanded(
      child: Container(
        color: const Color(0xC2FF2D2D),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                '月支出',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: moneyFormatText(monthExpense),
            ),
          ],
        ),
      ),
    ),
    const VerticalDivider(
      width: 1,
      thickness: 1,
      indent: 20,
      endIndent: 0,
    ),
    Expanded(
      child: Container(
        color: const Color(0xC2FF2D2D),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                '週支出',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: moneyFormatText(weekExpense),
            ),
          ],
        ),
      ),
    ),
    const VerticalDivider(
      width: 1,
      thickness: 1,
      indent: 20,
      endIndent: 0,
    ),
    Expanded(
      child: Container(
        color: const Color(0xC2FF2D2D),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                '日支出',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: moneyFormatText(dayExpense),
            ),
          ],
        ),
      ),
    ),
  ];
}

List<Widget> separateRow(int calendarIncome, int calendarExpense, int dayIncome, int dayExpense,
    String incomeText, String expenseText) {
  const fontSize = 11.0;
  return [
    Expanded(
      child: Container(
        color: const Color(0xC52DFF50),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                incomeText,
                style: const TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: moneyFormatText(calendarIncome),
            ),
          ],
        ),
      ),
    ),
    const VerticalDivider(
      width: 1,
      thickness: 1,
      indent: 20,
      endIndent: 0,
    ),
    Expanded(
      child: Container(
        color: const Color(0xC2FF2D2D),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                expenseText,
                style: const TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: moneyFormatText(calendarExpense),
            ),
          ],
        ),
      ),
    ),
    const VerticalDivider(
      width: 1,
      thickness: 1,
      indent: 20,
      endIndent: 0,
    ),
    Expanded(
      child: Container(
        color: const Color(0xC52DFF50),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                '日收入',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: moneyFormatText(dayIncome),
            ),
          ],
        ),
      ),
    ),
    const VerticalDivider(
      width: 1,
      thickness: 1,
      indent: 20,
      endIndent: 0,
    ),
    Expanded(
      child: Container(
        color: const Color(0xC2FF2D2D),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                '日支出',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: moneyFormatText(dayExpense),
            ),
          ],
        ),
      ),
    ),
  ];
}

List<Widget> totalRow(int calendarBalance, int dayBalance, String balanceText) {
  const fontSize = 11.0;
  return [
    Expanded(
      child: Container(
        color: const Color(0xC52DFF50),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                balanceText,
                style: const TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: moneyFormatText(calendarBalance),
            ),
          ],
        ),
      ),
    ),
    const VerticalDivider(
      width: 1,
      thickness: 1,
      indent: 20,
      endIndent: 0,
    ),
    Expanded(
      child: Container(
        color: const Color(0xC2FF2D2D),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                '日收支',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: moneyFormatText(dayBalance),
            ),
          ],
        ),
      ),
    )
  ];
}

Widget moneyFormatText(int money) {
  const moneySize = 22.0;
  const size = 10.0;
  if (money > 9999999999) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        moneyText('99+', moneySize),
        moneyText(' 億', size),
      ],
    );
  } else if (money > 100000000) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        moneyText((money / 100000000).toStringAsFixed(1), moneySize),
        moneyText(' 億', size),
      ],
    );
  } else if (money > 10000000) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        moneyText((money / 10000000).toStringAsFixed(1), moneySize),
        moneyText(' 千萬', size),
      ],
    );
  } else if (money > 1000000) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        moneyText((money / 1000000).toStringAsFixed(1), moneySize),
        moneyText(' 百萬', size),
      ],
    );
  } else if (money > 100000) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        moneyText((money / 100000).toStringAsFixed(1), moneySize),
        moneyText(' 十萬', size),
      ],
    );
  } else if (money > 10000) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        moneyText((money / 10000).toStringAsFixed(1), moneySize),
        moneyText(' 萬', size),
      ],
    );
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      moneyText(money.toStringAsFixed(0), moneySize),
      moneyText(' 元', size),
    ],
  );
}

Widget moneyText(String text, double size) {
  return Text(
    text,
    //textAlign:TextAlign.right,
    style: TextStyle(
      color: Colors.black,
      fontSize: size,
      fontWeight: size == 15 ? FontWeight.w600 : FontWeight.w400,
    ),
  );
}
