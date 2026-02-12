import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/notification_helper.dart';
import '../cubit/expense_cubit.dart';
import '../../data/models/expense_model.dart';
import '../widgets/expense_card.dart';
import 'package:intl/intl.dart';

class ExpenseListPage extends StatefulWidget {
  @override
  _ExpenseListPageState createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  NotificationHelper notificationHelper = NotificationHelper();
  String _selectedFilter = 'All';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ExpenseCubit>();
      cubit.fetchExpenses();      // DB
      cubit.loadSmsExpenses();    // SMS (ONCE)
    });
    notificationHelper.scheduleDailyReminder();
  }

  // Function to filter expenses based on the selected filter
  List<ExpenseModel> _filterExpenses(List<ExpenseModel> expenses) {
    List<ExpenseModel> filteredExpenses = [];
    final today = DateTime.now();

    if (_selectedFilter == 'Today') {
      filteredExpenses = expenses.where((expense) {
        final expenseDate = expense.date;
        return expenseDate.year == today.year &&
            expenseDate.month == today.month &&
            expenseDate.day == today.day;
      }).toList();
    } else if (_selectedFilter == 'This Week') {
      final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
      filteredExpenses = expenses.where((expense) {
        final expenseDate = expense.date;
        return expenseDate.isAfter(firstDayOfWeek.subtract(Duration(days: 1)));
      }).toList();
    } else if (_selectedFilter == 'This Month') {
      final firstDayOfMonth = DateTime(today.year, today.month, 1);
      filteredExpenses = expenses.where((expense) {
        final expenseDate = expense.date;
        return expenseDate.isAfter(firstDayOfMonth.subtract(Duration(days: 1)));
      }).toList();
    } else if (_selectedFilter == 'By Date' && _selectedDate != null) {
      filteredExpenses = expenses.where((expense) {
        final expenseDate = expense.date;
        return expenseDate.year == _selectedDate!.year &&
            expenseDate.month == _selectedDate!.month &&
            expenseDate.day == _selectedDate!.day;
      }).toList();
    } else {
      filteredExpenses = expenses;  // 'All' filter, show all expenses
    }

    // Sort the expenses by date in descending order
    filteredExpenses.sort((a, b) {
      return b.date.compareTo(a.date); // Sort by date in descending order
    });

    return filteredExpenses;
  }

  // Function to show date picker and set selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedFilter = 'By Date';  // Update the filter to show expenses for the selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.blue,
        title:Padding(padding:EdgeInsets.only(left:10),
        child:Text('Expense Tracker',style:TextStyle(color:Colors.white,fontSize:18),)),
        actions: [
          // Filter dropdown
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
                if (_selectedFilter != 'By Date') {
                  _selectedDate = null;  // Clear selected date if filter is not 'By Date'
                }
              });
            },
            itemBuilder: (context) {
              return ['All', 'Today', 'This Week', 'This Month', 'By Date'].map((filter) {
                return PopupMenuItem<String>(
                  value: filter,
                  child: Text(filter,style:TextStyle(color:Colors.black),),
                );
              }).toList();
            },

          ),
          // Button to select date
          IconButton(
            icon: Icon(Icons.calendar_today,color:Colors.white,),
            onPressed: () => _selectDate(context),
          ),
          // IconButton(
          //   icon: Icon(Icons.add,color:Colors.white,),
          //   onPressed: () => Navigator.pushNamed(context, '/addExpense'),
          // ),
        ],
      ),
      body: BlocBuilder<ExpenseCubit, List<ExpenseModel>>(
        builder: (context, expenses) {
          print('Expenses: ${expenses.map((e) => e.id).toList()}');  // Log the ids
          if (expenses.isEmpty) {
            return Center(child: Text('No expenses added yet.'));
          }

          // Filter and sort the expenses
          final filteredExpenses = _filterExpenses(expenses);

          return ListView.builder(
            itemCount: filteredExpenses.length,
            itemBuilder: (context, index) {
              final expense = filteredExpenses[index];

              return InkWell(
                  onTap: () {
                Navigator.pushNamed(
                  context,
                  '/summaryPage',
                  arguments: expense,
                );
              },

                child:ExpenseCard(
                expense: expense,
                onDelete: () {
                  if (expense.id != null) {
                    context.read<ExpenseCubit>().deleteExpense(expense.id!);  // Safe null check
                  }
                },
                // onEdit: () {
                //   if (expense.id != null) {
                //     Navigator.pushNamed(
                //       context,
                //       '/editExpense',
                //       arguments: expense,
                //     );
                //   }
                // },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor:Colors.blue,
        onPressed: () {
          Navigator.pushNamed(context, '/summaryPage');  // Navigate to summary page
        },
        child: Icon(Icons.show_chart,color:Colors.white,),  // Icon for summary
        tooltip: 'Summary',
      ),

    );
  }
}
