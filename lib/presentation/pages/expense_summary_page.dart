import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import '../cubit/expense_cubit.dart';

enum SummaryType { weekly, monthly, yearly }

class ExpenseSummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<ExpenseSummaryPage> {
  SummaryType selectedSummary = SummaryType.weekly;
  ExpenseCategory selectedCategory = ExpenseCategory.miscellaneous;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Expense Summary",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Overview",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _buildSummarySelector(),

            const SizedBox(height: 20),

            _buildCategorySelector(),

            const SizedBox(height: 30),

            BlocBuilder<ExpenseCubit, List<ExpenseModel>>(
              builder: (context, expenses) {
                if (expenses.isEmpty) {
                  return const Center(
                    child: Text("No expenses available."),
                  );
                }

                final totalExpense = _getTotalExpense(expenses);

                return Column(
                  children: [
                    _buildSummaryCard(totalExpense),
                    const SizedBox(height: 30),
                    _buildPieChart((expenses),
                    )// ✅ pass list here
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔵 Segmented Summary Selector
  Widget _buildSummarySelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: SummaryType.values.map((type) {
          final isSelected = selectedSummary == type;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedSummary = type;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    type.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 🟢 Category Chips
  Widget _buildCategorySelector() {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ExpenseCategory.values.map((category) {
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                category.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.blue,
              backgroundColor: Colors.grey.shade200,
              onSelected: (_) {
                setState(() {
                  selectedCategory = category;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(List<ExpenseModel> expenses) {
    final Map<ExpenseCategory, double> categoryTotals = {};

    final now = DateTime.now();
    final startOfWeek =
    _dateOnly(now.subtract(Duration(days: now.weekday - 1)));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);

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

      if (include) {
        categoryTotals.update(
          expense.category,
              (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
    }

    if (categoryTotals.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];

    int index = 0;

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              sections: categoryTotals.entries.map((entry) {
                final color = colors[index % colors.length];
                index++;

                final percentage =
                ((entry.value / total) * 100).toStringAsFixed(1);

                return PieChartSectionData(
                  color: color,
                  value: entry.value,
                  radius: 85,
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                  title: ((entry.value / total) * 100) > 8   // 👈 show only if >8%
                      ? "${((entry.value / total) * 100).toStringAsFixed(0)}%"
                      : "",
                  titlePositionPercentageOffset: 0.6,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 🔥 Legend (Very Important for Clarity)
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: categoryTotals.entries.map((entry) {
            final color =
            colors[categoryTotals.keys.toList().indexOf(entry.key) %
                colors.length];

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${entry.key.name} (₹${entry.value.toStringAsFixed(0)})",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // 🟣 Premium Summary Card
  Widget _buildSummaryCard(double totalExpense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF5F6FFF), Color(0xFF8F94FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Spending",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "₹ ${totalExpense.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedSummary.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // 🔎 Date Filter Logic
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

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

      final matchesCategory =
          expense.category == selectedCategory;

      if (include && matchesCategory) {
        total += expense.amount;
      }
    }

    return total;
  }


}