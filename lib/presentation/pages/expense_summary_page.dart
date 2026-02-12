import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import '../cubit/expense_cubit.dart';

/// Summary type enum
enum SummaryType { weekly, monthly, yearly }


class ExpenseSummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<ExpenseSummaryPage> {
  SummaryType selectedSummary = SummaryType.weekly;
  ExpenseCategory selectedCategory = ExpenseCategory.rent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Expense Summary',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment:MainAxisAlignment.center,
        children: [

          /// Toggle: Weekly / Monthly / Yearly
            Container(
              width: MediaQuery.of(context).size.width - 32,
              height:MediaQuery.of(context).size.height/2,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 76),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Summary Type Dropdown ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<SummaryType>(
                    value: selectedSummary,
                    decoration: const InputDecoration(
                      labelText: 'Summary Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedSummary = value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: SummaryType.weekly, child: Text('Weekly')),
                      DropdownMenuItem(value: SummaryType.monthly, child: Text('Monthly')),
                      DropdownMenuItem(value: SummaryType.yearly, child: Text('Yearly')),
                    ],
                  ),
                ),

                // --- Category Dropdown ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<ExpenseCategory>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: ExpenseCategory.rent, child: Text('Rent')),
                      DropdownMenuItem(value: ExpenseCategory.food, child: Text('Food')),
                      DropdownMenuItem(value: ExpenseCategory.fuel, child: Text('Fuel')),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // --- Total Expense Card ---
                BlocBuilder<ExpenseCubit, List<ExpenseModel>>(
                  builder: (context, expenses) {
                    if (expenses.isEmpty) {
                      return const Center(
                        child: Text('No expenses available for summary.'),
                      );
                    }

                    final totalExpense = _getTotalExpense(expenses);

                    return Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width - 32,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Left: Labels + Amount
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Total Expenses',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  selectedSummary == SummaryType.weekly
                                      ? 'This Week'
                                      : selectedSummary == SummaryType.monthly
                                      ? 'This Month'
                                      : 'This Year',
                                  style: const TextStyle(fontSize: 14, color: Colors.white),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '₹ ${totalExpense.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                              ],
                            ),

                            /// Right: Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                size: 40,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
              ]
      )
    );
  }

  /// Reusable Radio Button


  DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);


  /// Calculate total expense
  double _getTotalExpense(List<ExpenseModel> expenses) {
    final now = DateTime.now();

    final startOfWeek =
    _dateOnly(now.subtract(Duration(days: now.weekday - 1)));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);

    double total = 0.0;

    for (final expense in expenses) {
      final expenseDate = _dateOnly(expense.date);
      bool include = false;

      switch (selectedSummary) {
        case SummaryType.weekly:
          include = !expenseDate.isBefore(startOfWeek);
          break;

        case SummaryType.monthly:
          include = !expenseDate.isBefore(startOfMonth);
          break;

        case SummaryType.yearly:
          include = !expenseDate.isBefore(startOfYear);
          break;
      }

      // ✅ ADD CATEGORY FILTER HERE
      final matchesCategory =
          selectedCategory == null || expense.category == selectedCategory;

      if (include && matchesCategory) {
        total += expense.amount;
      }
    }

    return total;
  }

  double getCategorySummary(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    double total = 0;

    DateTime startDate;

    switch (selectedSummary) {
      case SummaryType.weekly:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;

      case SummaryType.monthly:
        startDate = DateTime(now.year, now.month, 1);
        break;

      case SummaryType.yearly:
        startDate = DateTime(now.year, 1, 1);
        break;
    }

    for (final expense in expenses) {
      final matchesDate = expense.date.isAfter(startDate);
      final matchesCategory =
          selectedCategory == null || expense.category == selectedCategory;

      if (matchesDate && matchesCategory) {
        total += expense.amount;
      }
    }

    return total;
  }


}
