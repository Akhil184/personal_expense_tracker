

import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(Expense expense);
  Future<List<Expense>> getExpenses();
  Future<void> deleteExpense(String id);
  Future<void> updateExpense(Expense expense);

  // New method to get summarized expenses
  Future<List<Map<String, dynamic>>> getSummary(DateTime startDate, DateTime endDate);
}

