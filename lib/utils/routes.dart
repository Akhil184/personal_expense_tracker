import 'package:flutter/material.dart';
import '../data/models/expense_category.dart';
import '../data/models/expense_model.dart';
import '../presentation/pages/add_expense_page.dart';
import '../presentation/pages/edit_expense_page.dart';
import '../presentation/pages/expense_list_page.dart';
import '../presentation/pages/expense_summary_page.dart';


class AppRoutes {
  static const String expenseList = '/';
  static const String addExpense = '/addExpense';
  static const String editExpense = '/editExpense';
  static const String summaryPage = '/summaryPage';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case expenseList:
        return MaterialPageRoute(builder: (_) => ExpenseListPage());
      case addExpense:
        return MaterialPageRoute(builder: (_) => AddExpensePage());
      case editExpense:
      // Fetch the argument (ExpenseModel) from the route
        final expense = settings.arguments as ExpenseModel?;
        return MaterialPageRoute(
          builder: (_) => EditExpensePage(
            expense: expense ?? ExpenseModel(
              id:null, // Provide default values
              amount: 0.0,
              date: DateTime.now(),
              description: '',
              category: ExpenseCategory.food,
            ),
          ),
        );
      case summaryPage:
      // Fetch the argument (ExpenseModel) from the route
        final expense = settings.arguments as ExpenseModel?;
        return MaterialPageRoute(
          builder: (_) => ExpenseSummaryPage(

          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Page not found!')),
          ),
        );
    }
  }
}
