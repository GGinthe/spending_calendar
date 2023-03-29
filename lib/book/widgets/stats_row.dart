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
    String incomeText = '月收入';
    String expenseText = '月支出';
    String balanceText = '月平衡';
    if (state.calendarFormat == CalendarFormat.month) {
      final total = getMonthTotal(selectedDay ?? now);
      calendarIncome = total.first;
      calendarExpense = total.last * -1;
      calendarBalance = total.first + total.last;
      incomeText = '月收入';
      expenseText = '月支出';
      balanceText = '月平衡';
    } else if (state.calendarFormat == CalendarFormat.week) {
      final total = getWeekTotal(selectedDay ?? now);
      calendarIncome = total.first;
      calendarExpense = total.last * -1;
      calendarBalance = total.first + total.last;
      incomeText = '週收入';
      expenseText = '週支出';
      balanceText = '週平衡';
    }
    final dayTotal = getDayTotal(selectedDay ?? now);
    final dayIncome = dayTotal.first;
    final dayExpense = dayTotal.last * -1;
    final dayBalance = dayTotal.first + dayTotal.last;

    return GestureDetector(
      onTap: () {
        context.read<BookBloc>().add(
              const CalendarBalanceChanged(),
            );
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
            else
              ...separateRow(calendarIncome, calendarExpense, dayIncome, dayExpense, incomeText, expenseText)
          ],
        ),
      ),
    );
  }
}

List<Expanded> separateRow(int calendarIncome, int calendarExpense, int dayIncome, int dayExpense,
    String incomeText, String expenseText) {
  return [
    Expanded(
      child: Container(
        color: const Color(0x652DFF50),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                incomeText,
                style: const TextStyle(
                  fontSize: 20.0,
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
    Expanded(
      child: Container(
        color: const Color(0x80FF2D2D),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                expenseText,
                style: const TextStyle(
                  fontSize: 20.0,
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
    Expanded(
      child: Container(
        color: const Color(0x652DFF50),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                '日收入',
                style: TextStyle(
                  fontSize: 20.0,
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
    Expanded(
      child: Container(
        color: const Color(0x80FF2D2D),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                '日支出',
                style: TextStyle(
                  fontSize: 20.0,
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

List<Expanded> totalRow(int calendarBalance, int dayBalance, String balanceText) {
  return [
    Expanded(
      child: Container(
        color: const Color(0x652DFF50),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                balanceText,
                style: const TextStyle(
                  fontSize: 20.0,
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
    Expanded(
      child: Container(
        color: const Color(0x80FF2D2D),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                '日平衡',
                style: TextStyle(
                  fontSize: 20.0,
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
  const moneySize = 25.0;
  const size = 15.0;
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
      moneyText(money.toStringAsFixed(0), 25.0),
      moneyText(' 元', 15.0),
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
