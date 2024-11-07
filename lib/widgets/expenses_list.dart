import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:new_expense/widgets/expense_item.dart';
import 'package:new_expense/models/expense.dart';

import 'chart/chart.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
    required this.onEditExpense,
  });

  final List<Expense> expenses;
  final void Function(Expense expense) onRemoveExpense;
  final void Function(Expense expense) onEditExpense;

  // Method to calculate total expenses
  double getTotalExpenses() {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text('Nothing Yet.'),
      );
    }

    return Column(
      children: [
        // Display the Chart widget
        Chart(expenses: expenses),

        // Display total expenses below the Chart
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            'Total Expenses: \$${getTotalExpenses().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        // Display the expenses list
        Expanded(
          child: ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (ctx, index) {
              final expense = expenses[index];
              return Slidable(
                key: ValueKey(expense),
                endActionPane: ActionPane(
                  motion: const StretchMotion(),
                  children: [
                    // Edit action
                    SlidableAction(
                      borderRadius: BorderRadius.circular(10),
                      onPressed: (_) => onEditExpense(expense),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      borderRadius: BorderRadius.circular(10),
                      onPressed: (_) => onRemoveExpense(expense),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ExpenseItem(expense: expense), // Display each expense
              );
            },
          ),
        ),
      ],
    );
  }
}
