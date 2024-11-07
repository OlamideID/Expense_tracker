import 'package:new_expense/models/expense.dart';

class ExpenseBucket {
  final Category category;
  final List<Expense> expenses;

  double get totalExpenses => expenses.fold(0, (sum, e) => sum + e.amount);

  ExpenseBucket.forCategory(
    this.category,
    List<Expense> allExpenses,
  ) : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

  ExpenseBucket({
    required this.category,
    required this.expenses,
  });
}
