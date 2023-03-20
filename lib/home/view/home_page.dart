import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spending_calendar/edit_task/edit_task.dart';
import 'package:spending_calendar/edit_spending/edit_spending.dart';
import 'package:spending_calendar/home/home.dart';
import 'package:spending_calendar/book/book.dart';
import 'package:spending_calendar/calendar/calendar.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((HomeCubit cubit) => cubit.state.tab);

    return Scaffold(
      body: IndexedStack(
        index: selectedTab.index,
        children: const [CalendarPage(), BookPage()],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        key: const Key('homeView_addTask_floatingActionButton'),
        onPressed: ()=>{
          if(selectedTab == HomeTab.calendar)
            Navigator.of(context).push(EditTaskPage.route())
          else if(selectedTab == HomeTab.spending)
            Navigator.of(context).push(EditSpendingPage.route())
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _HomeTabButton(
              groupValue: selectedTab,
              value: HomeTab.calendar,
              icon: const Icon(Icons.calendar_today),
            ),
            _HomeTabButton(
              groupValue: selectedTab,
              value: HomeTab.spending,
              icon: const Icon(Icons.attach_money),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTabButton extends StatelessWidget {
  const _HomeTabButton({
    required this.groupValue,
    required this.value,
    required this.icon,
  });

  final HomeTab groupValue;
  final HomeTab value;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.read<HomeCubit>().setTab(value),
      iconSize: 32,
      color:
      groupValue != value ? null : Theme.of(context).colorScheme.secondary,
      icon: icon,
    );
  }
}

