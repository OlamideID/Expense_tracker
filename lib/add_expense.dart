import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:new_expense/widgets/expenses_list.dart';
import 'package:new_expense/models/expense.dart';
import 'package:new_expense/new_exp_page.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  late Box<Expense> _expenseBox;
  final List<Expense> _registeredExpenses = [];

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _expenseBox = await Hive.openBox<Expense>('expenses');
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _registeredExpenses.clear();
      _registeredExpenses.addAll(_expenseBox.values);
    });
  }

  Future<void> _saveExpense(Expense expense) async {
    await _expenseBox.add(expense);
    _loadExpenses(); // Refresh the list
  }

  Future<void> _updateExpense(Expense expense, int index) async {
    await _expenseBox.putAt(index, expense);
    _loadExpenses(); // Refresh the list
  }

  Future<void> _deleteExpense(int index) async {
    await _expenseBox.deleteAt(index);
    _loadExpenses(); // Refresh the list
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
      _saveExpense(expense);
    });
  }

  void _editExpense(Expense expense, int index) {
    setState(() {
      _registeredExpenses[index] = expense;
      _updateExpense(expense, index);
    });
  }

  void _removeExpense(Expense expense) {
    final index = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.removeAt(index);
      _deleteExpense(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
      ),
      body: ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
        onEditExpense: (expense) {
          final index = _registeredExpenses.indexOf(expense);
          _showAddOrEditExpense(context, expense, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => _showAddOrEditExpense(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOrEditExpense(BuildContext context,
      [Expense? expense, int? index]) {
    showModalBottomSheet(
      enableDrag: true,
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: NewExpense(
            initialExpense: expense,
            onSaveExpense: (newExpense) {
              if (index != null) {
                _editExpense(newExpense, index);
              } else {
                _addExpense(newExpense);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _expenseBox.close();
    super.dispose();
  }
}
