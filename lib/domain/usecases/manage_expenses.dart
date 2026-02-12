import '../../data/datasources/expense_local_data_source.dart';
import '../../data/models/expense_model.dart';

class ManageExpenses {
  final ExpenseLocalDataSource dataSource;

  ManageExpenses(this.dataSource);

  // Add a new expense
  Future<void> addExpense(ExpenseModel expense) => dataSource.insertExpense(expense);

  // Get all expenses
  Future<List<ExpenseModel>> getExpenses() => dataSource.fetchExpenses();

  // Delete an expense by ID
  Future<void> deleteExpense(int id) => dataSource.deleteExpense(id);

  // Update an existing expense
  Future<void> updateExpense(ExpenseModel updatedExpense) => dataSource.updateExpense(updatedExpense);
}
