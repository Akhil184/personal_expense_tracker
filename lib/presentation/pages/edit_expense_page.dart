import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import '../../domain/entities/expense.dart';
import '../cubit/expense_cubit.dart';

class EditExpensePage extends StatefulWidget {
  final ExpenseModel expense;

  EditExpensePage({required this.expense});

  @override
  _EditExpensePageState createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();  // Controller for date
  DateTime? _selectedDate;
  late ExpenseCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the current expense data
    descriptionController.text = widget.expense.description;
    amountController.text = widget.expense.amount.toString();
    _selectedCategory = widget.expense.category;
    _selectedDate = widget.expense.date; // Use the existing date by default
    dateController.text = _selectedDate != null ? DateFormat.yMMMd().format(_selectedDate!) : ''; // Set the initial date
  }

  // Function to show date picker and set the selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dateController.text = DateFormat.yMMMd().format(picked!); // Update the text field with the selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Description input
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            // Amount input
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            // Date Picker input
            TextField(
              controller: dateController,
              readOnly: true,  // Make it read-only so the user can't type directly
              decoration: InputDecoration(
                labelText: 'Select Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),  // Trigger date picker on tap
            ),
            SizedBox(height: 20),
            // Save Changes Button
            ElevatedButton(
              onPressed: () {
                if (descriptionController.text.isEmpty ||
                    amountController.text.isEmpty ||
                    _selectedDate == null) {
                  // Show a warning if any field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                } else {
                  // Convert ExpenseModel to Expense (domain entity)
                  final updatedExpense = Expense(
                    id: widget.expense.id, // Pass the ID from the existing expense
                    description: descriptionController.text,
                    amount: double.parse(amountController.text),
                    date: _selectedDate!,
                    category: _selectedCategory,
                  );

                  // Use the cubit's update method
                  context.read<ExpenseCubit>().updateExpense(updatedExpense);

                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Set your desired background color here
                foregroundColor: Colors.white, // Set the text color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Optional: adjust padding
              ),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
