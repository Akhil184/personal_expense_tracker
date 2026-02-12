import 'package:intl/intl.dart';

import 'expense_category.dart';

class ExpenseModel {
  final int? id;
  final String description;
  final double amount;
  final DateTime date;
  final ExpenseCategory category; // ✅ added

  ExpenseModel({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });

  // Convert to Map (DB / API safe)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'category': category.name, // stored as string
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      description: map['description'] ?? '',
      amount: map['amount'] != null ? map['amount'].toDouble() : 0.0,
      date: map['date'] != null
          ? DateFormat('yyyy-MM-dd').parse(map['date'])
          : DateTime.now(),
      category: map['category'] != null
          ? ExpenseCategory.values.firstWhere(
            (e) => e.name == map['category'],
        orElse: () => ExpenseCategory.food, // fallback
      )
          : ExpenseCategory.food, // fallback for old data
    );
  }
}
