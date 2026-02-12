import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/models/expense_model.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/manage_expenses.dart';
import '../../sms/sms_reader.dart';

class ExpenseCubit extends Cubit<List<ExpenseModel>> {
  final ManageExpenses manageExpenses;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  ExpenseCubit(this.manageExpenses,this.flutterLocalNotificationsPlugin) : super([]);

  // Fetch expenses from the use case
  Future<void> fetchExpenses() async {
    try {
      final expenses = await manageExpenses.getExpenses();
      emit(expenses); // Emit the updated expenses list
    } catch (e) {
      emit([]);  // In case of error, emit empty list or handle error state
    }
  }

  // Add expense using the manageExpenses use case
  Future<void> addExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel(
        id: null,  // ID should be null, database will generate the ID
        description: expense.description,
        amount: expense.amount,
        date: expense.date,
          category: expense.category,
      );
      await manageExpenses.addExpense(expenseModel);
      fetchExpenses();

      // Show notification after adding expense
      _showNotification('Expense Added', 'Added ${expense.amount}');
    } catch (e) {
      print('Error adding expense: $e');
    }
  }

  Future<void> loadSmsExpenses() async {
    final smsExpenses = await readDebitSms();
    emit([...state, ...smsExpenses]); // merge
  }

  // Show local notification
  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expense_channel',
      'Expense Notifications',
      channelDescription: 'Notifications for expense tracking',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  // Update expense using the manageExpenses use case
  Future<void> updateExpense(Expense updatedExpense) async {
    try {
      // Convert updatedExpense (domain) to ExpenseModel (data layer)
      final updatedExpenseModel = ExpenseModel(
        id: updatedExpense.id,  // ID should already be available in domain model
        description: updatedExpense.description,
        amount: updatedExpense.amount,
        date: updatedExpense.date, category: updatedExpense.category,

      );

      // Call the use case to update the expense
      await manageExpenses.updateExpense(updatedExpenseModel);  // Use the use case to update the expense

      // Fetch updated expenses list after update
      fetchExpenses();
    } catch (e) {
      // Handle errors if necessary
      print('Error updating expense: $e');
    }
  }



  // Delete expense using the manageExpenses use case
  Future<void> deleteExpense(int id) async {
    try {
      await manageExpenses.deleteExpense(id);
      fetchExpenses();  // Fetch updated expenses after deletion
    } catch (e) {
      // Handle errors if necessary
      print('Error deleting expense: $e');
    }
  }


}
