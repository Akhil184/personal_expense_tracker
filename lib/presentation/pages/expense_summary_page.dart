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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
            ),
          ),
        ),
        title: const Text(
          'Expense Summary',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// FILTER CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [

                    /// Summary Type Dropdown
                    DropdownButtonFormField<SummaryType>(
                      value: selectedSummary,
                      decoration: InputDecoration(
                        labelText: 'Summary Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedSummary = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                            value: SummaryType.weekly,
                            child: Text('Weekly')),
                        DropdownMenuItem(
                            value: SummaryType.monthly,
                            child: Text('Monthly')),
                        DropdownMenuItem(
                            value: SummaryType.yearly,
                            child: Text('Yearly')),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Category Dropdown
                    DropdownButtonFormField<ExpenseCategory>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                            value: ExpenseCategory.rent,
                            child: Text('Rent')),
                        DropdownMenuItem(
                            value: ExpenseCategory.food,
                            child: Text('Food')),
                        DropdownMenuItem(
                            value: ExpenseCategory.fuel,
                            child: Text('Fuel')),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// SUMMARY CARD
              BlocBuilder<ExpenseCubit, List<ExpenseModel>>(
                builder: (context, expenses) {
                  if (expenses.isEmpty) {
                    return const Text(
                      'No expenses available.',
                      style: TextStyle(fontSize: 16),
                    );
                  }

                  final totalExpense = _getTotalExpense(expenses);

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.shade200,
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        /// LEFT SIDE
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Expenses',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              selectedSummary ==
                                  SummaryType.weekly
                                  ? 'This Week'
                                  : selectedSummary ==
                                  SummaryType.monthly
                                  ? 'This Month'
                                  : 'This Year',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '₹ ${totalExpense.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        /// RIGHT ICON
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
