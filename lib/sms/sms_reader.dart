import 'package:another_telephony/telephony.dart';
import '../data/models/expense_category.dart';
import '../data/models/expense_model.dart';

final Telephony telephony = Telephony.instance;

Future<List<ExpenseModel>> readDebitSms() async {
  final permission = await telephony.requestPhoneAndSmsPermissions;
  if (permission != true) return [];

  final messages = await telephony.getInboxSms(
    columns: [SmsColumn.BODY, SmsColumn.DATE],
  );

  List<ExpenseModel> expenses = [];

  for (final msg in messages) {
    final body = msg.body?.toLowerCase() ?? '';

    if (_isDebitSms(body)) {
      final amount = _extractAmount(body);

      if (amount != null && msg.date != null) {
        expenses.add(
          ExpenseModel(
            description: 'Bank Debit', // ✅ REQUIRED
            amount: amount,
            date: DateTime.fromMillisecondsSinceEpoch(msg.date!),
            category: _detectCategoryFromSms(body),
          ),
        );
      }
    }
  }

  return expenses;
}

bool _isDebitSms(String body) {
  return body.contains('debit') ||
      body.contains('spent') ||
      body.contains('paid') ||
      body.contains('purchase') ||
      body.contains('withdrawn');
}

double _extractAmount(String message) {
  final regex = RegExp(
    r'(?:Rs\.?|INR|₹)?\s?([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  final match = regex.firstMatch(message);
  if (match == null) return 0.0;

  String amountStr = match.group(1)!;

  // Remove commas
  amountStr = amountStr.replaceAll(',', '');

  return double.tryParse(amountStr) ?? 0.0;
}

ExpenseCategory _detectCategoryFromSms(String body) {

  // 🍔 Food Delivery
  if (body.contains('swiggy') ||
      body.contains('zomato') ||
      body.contains('ubereats') ||
      body.contains('blinkit')) {
    return ExpenseCategory.food;
  }

  // ⛽ Fuel
  if (body.contains('petrol') ||
      body.contains('fuel') ||
      body.contains('hpcl') ||
      body.contains('ioc') ||
      body.contains('bharat petroleum')) {
    return ExpenseCategory.fuel;
  }

  // 🏠 Rent
  if (body.contains('rent')) {
    return ExpenseCategory.rent;
  }

  // 🛒 Shopping
  if (body.contains('amazon') ||
      body.contains('flipkart') ||
      body.contains('myntra') ||
      body.contains('meesho')) {
    return ExpenseCategory.shopping;
  }

  // 🚕 Transport
  if (body.contains('ola') ||
      body.contains('uber') ||
      body.contains('rapido')) {
    return ExpenseCategory.transport;
  }

  // 🎬 Subscriptions
  if (body.contains('netflix') ||
      body.contains('spotify') ||
      body.contains('prime') ||
      body.contains('hotstar')) {
    return ExpenseCategory.subscriptions;
  }

  // 🏦 EMI / Loan
  if (body.contains('emi') ||
      body.contains('loan')) {
    return ExpenseCategory.loanRepayment;
  }

  // 💳 Credit Card
  if (body.contains('credit card')) {
    return ExpenseCategory.creditCardBill;
  }

  // 🏥 Medical
  if (body.contains('hospital') ||
      body.contains('pharmacy') ||
      body.contains('apollo')) {
    return ExpenseCategory.medical;
  }

  return ExpenseCategory.miscellaneous;
}