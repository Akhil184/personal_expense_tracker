import '../../data/models/expense_category.dart';


class Expense {
  final int? id;
  final String description;
  final double amount;
  final DateTime date;
  final ExpenseCategory category; // ✅ ADD THIS

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}