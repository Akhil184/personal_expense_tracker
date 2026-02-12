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
        children: [
          const SizedBox(height: 12),

          /// Toggle: Weekly / Monthly / Yearly
         Padding(padding:EdgeInsets.only(left:15,right:15),
        child:DropdownButtonFormField<SummaryType>(
          value: selectedSummary,
          isDense: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: DropdownButtonFormField<ExpenseCategory>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
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






          const SizedBox(height: 10),

          /// Summary List
          Expanded(
            child: BlocBuilder<ExpenseCubit, List<ExpenseModel>>(
              builder: (context, expenses) {
                if (expenses.isEmpty) {
                  return const Center(
                    child: Text('No expenses available for summary.'),
                  );
                }

                final totalExpense = _getTotalExpense(expenses);

                return ListView(
                  children: [
                    ListTile(
                      title: const Text('Total Expenses'),
                      subtitle: Text(
                        selectedSummary == SummaryType.weekly
                            ? 'Total for this week'
                            : selectedSummary == SummaryType.monthly
                            ? 'Total for this month'
                            : 'Total for this year',
                      ),
                      trailing: Text(
                        '₹ ${totalExpense.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable Radio Button
  Widget _buildRadio({
    required String label,
    required SummaryType value,
  }) {
    final bool isSelected = selectedSummary == value;

    return Row(
      children: [
        Radio<SummaryType>(
          value: value,
          groupValue: selectedSummary,
          activeColor: Colors.blue,
          onChanged: (val) {
            setState(() {
              selectedSummary = val!;
            });
          },
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.black87,
          ),
        ),
      ],
    );
  }

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
