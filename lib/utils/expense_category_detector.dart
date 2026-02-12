import '../data/models/expense_category.dart';


ExpenseCategory detectCategoryFromTitle(String title) {
  final text = title.toLowerCase();

  if (text.contains('swiggy') ||
      text.contains('zomato') ||
      text.contains('blinkit')) {
    return ExpenseCategory.food;
  }

  if (text.contains('petrol') || text.contains('fuel')) {
    return ExpenseCategory.fuel;
  }

  if (text.contains('rent')) {
    return ExpenseCategory.rent;
  }

  return ExpenseCategory.bank;
}