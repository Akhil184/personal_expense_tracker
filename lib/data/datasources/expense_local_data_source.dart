import 'package:sqflite/sqflite.dart';
import '../models/expense_model.dart';
import 'expense_database_helper.dart';

class ExpenseLocalDataSource {
  static const _tableName = 'expenses';

  // Insert an expense into the database
  Future<void> insertExpense(ExpenseModel expense) async {
    final db = await DatabaseHelper.initDatabase();

    // Insert the expense
    await db.insert(
      _tableName,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // After inserting, retrieve the last inserted id
    final insertedId = await db.rawQuery('SELECT last_insert_rowid()');
    print("Inserted ID: $insertedId");  // Log the inserted ID
  }


  // Fetch all expenses from the database
  Future<List<ExpenseModel>> fetchExpenses() async {
    final db = await DatabaseHelper.initDatabase();
    final results = await db.query(_tableName, orderBy: 'date DESC');
    return results.map((map) => ExpenseModel.fromMap(map)).toList(); // Convert Map back to ExpenseModel
  }

  // Delete an expense from the database by ID
  Future<void> deleteExpense(int id) async {
    final db = await DatabaseHelper.initDatabase();
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update an existing expense in the database
  Future<void> updateExpense(ExpenseModel updatedExpense) async {
    final db = await DatabaseHelper.initDatabase();
    await db.update(
      _tableName,
      updatedExpense.toMap(), // Convert ExpenseModel to Map
      where: 'id = ?',
      whereArgs: [updatedExpense.id], // Update the record based on its ID
    );
  }
}
