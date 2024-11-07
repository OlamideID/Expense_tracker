import 'package:hive_flutter/hive_flutter.dart';
import 'package:new_expense/models/expense.dart';

late Box<Expense> expenseBox;

Future<void> initHive() async {
  // Open the 'expenses' box only if it's not already open
  if (!Hive.isBoxOpen('expenses')) {
    expenseBox = await Hive.openBox<Expense>('expenses');
  } else {
    expenseBox = Hive.box<Expense>('expenses');
  }
}

Box<Expense> getExpenses() {
  return expenseBox;
}
