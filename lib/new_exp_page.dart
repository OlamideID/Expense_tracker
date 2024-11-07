import 'package:flutter/material.dart';
import 'package:new_expense/models/expense.dart';

class NewExpense extends StatefulWidget {
  final Expense? initialExpense;
  final void Function(Expense expense) onSaveExpense;

  const NewExpense(
      {this.initialExpense, required this.onSaveExpense, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewExpenseState createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.initialExpense != null) {
      _titleController.text = widget.initialExpense!.title;
      _amountController.text = widget.initialExpense!.amount.toString();
      _selectedDate = widget.initialExpense!.date;
      _selectedCategory = widget.initialExpense!.category;
    }
  }

  void _submitData() {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;

    if (enteredTitle.isEmpty ||
        enteredAmount <= 0 ||
        _selectedDate == null ||
        _selectedCategory == null) {
      // Show a dialog if any required field is missing or invalid
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text('All fields must be input correctly.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }

    widget.onSaveExpense(
      Expense(
        title: enteredTitle.isNotEmpty
            ? enteredTitle[0].toUpperCase() +
                enteredTitle.substring(1).toLowerCase()
            : enteredTitle, // Handle empty string if needed
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
            ),
          ),
          TextField(
            controller: _amountController,
            decoration:
                const InputDecoration(labelText: 'Amount', prefixText: '\$'),
            keyboardType: TextInputType.number,
          ),
          DropdownButtonFormField<Category>(
            decoration: const InputDecoration(labelText: 'Category'),
            value: _selectedCategory,
            items: Category.values.map((Category category) {
              return DropdownMenuItem<Category>(
                value: category,
                child: Row(
                  children: [
                    Icon(categoryIcons[category]),
                    const SizedBox(width: 8),
                    Text(category.toString().split('.').last),
                  ],
                ),
              );
            }).toList(),
            onChanged: (Category? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (selectedDate != null) {
                setState(() => _selectedDate = selectedDate);
              }
            },
            child: Text(_selectedDate == null
                ? 'Choose Date'
                : 'Selected Date: ${formatter.format(_selectedDate!)}'),
          ),
          ElevatedButton(
            onPressed: _submitData,
            child: Text(
                widget.initialExpense == null ? 'Add Expense' : 'Save Changes'),
          ),
        ],
      ),
    );
  }
}
