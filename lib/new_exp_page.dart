import 'package:flutter/material.dart';
import 'package:new_expense/models/expense.dart';

class NewExpense extends StatefulWidget {
  final Expense? initialExpense;
  final void Function(Expense expense) onSaveExpense;

  const NewExpense({
    this.initialExpense,
    required this.onSaveExpense,
    super.key,
  });

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  Category? _selectedCategory;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;
  final _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.initialExpense != null) {
      _titleController.text = widget.initialExpense!.title;
      _amountController.text = widget.initialExpense!.amount.toString();
      _selectedDate = widget.initialExpense!.date;
      _selectedCategory = widget.initialExpense!.category;
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _animationController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Color _getCategoryColor(Category category) {
    final colors = {
      Category.food: Colors.orange,
      Category.travel: Colors.blue,
      Category.leisure: Colors.purple,
      Category.work: Colors.green,
      Category.other: Colors.grey,
    };
    return colors[category] ?? Colors.blue;
  }

  void _submitData() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      widget.onSaveExpense(
        Expense(
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text),
          date: _selectedDate!,
          category: _selectedCategory!,
        ),
      );
    }
  }

  Widget _buildFormField(String label, Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: colorScheme.background,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.initialExpense == null
                      ? 'New Expense'
                      : 'Edit Expense',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withOpacity(0.1),
                        colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: colorScheme,
                        ),
                        child: Stepper(
                          currentStep: _currentStep,
                          onStepContinue: () {
                            setState(() {
                              if (_currentStep < 3) _currentStep++;
                            });
                          },
                          onStepCancel: () {
                            setState(() {
                              if (_currentStep > 0) _currentStep--;
                            });
                          },
                          onStepTapped: (step) {
                            setState(() => _currentStep = step);
                          },
                          controlsBuilder: (context, controls) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                children: [
                                  if (_currentStep > 0)
                                    TextButton.icon(
                                      onPressed: controls.onStepCancel,
                                      icon: const Icon(Icons.arrow_back),
                                      label: const Text('Back'),
                                    ),
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: _currentStep == 3
                                        ? _submitData
                                        : controls.onStepContinue,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    icon: Icon(_currentStep == 3
                                        ? Icons.check
                                        : Icons.arrow_forward),
                                    label: Text(
                                      _currentStep == 3 ? 'Save' : 'Continue',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          steps: [
                            Step(
                              title: const Text('Title'),
                              content: TextFormField(
                                controller: _titleController,
                                focusNode: _focusNodes[0],
                                decoration: InputDecoration(
                                  hintText: 'What did you spend on?',
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.shopping_bag),
                                ),
                                validator: (value) =>
                                    value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              isActive: _currentStep >= 0,
                            ),
                            Step(
                              title: const Text('Amount'),
                              content: TextFormField(
                                controller: _amountController,
                                focusNode: _focusNodes[1],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.attach_money),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Required';
                                  if (double.tryParse(value!) == null)
                                    return 'Invalid amount';
                                  return null;
                                },
                              ),
                              isActive: _currentStep >= 1,
                            ),
                            Step(
                              title: const Text('Category'),
                              content: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: Category.values.map((category) {
                                    final isSelected =
                                        _selectedCategory == category;
                                    final color = _getCategoryColor(category);
                                    return GestureDetector(
                                      onTap: () {
                                        setState(
                                            () => _selectedCategory = category);
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? color.withOpacity(0.2)
                                              : colorScheme.surface,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          border: Border.all(
                                            color: isSelected
                                                ? color
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              categoryIcons[category],
                                              color: isSelected
                                                  ? color
                                                  : colorScheme.onSurface,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              category
                                                  .toString()
                                                  .split('.')
                                                  .last,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? color
                                                    : colorScheme.onSurface,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              isActive: _currentStep >= 2,
                            ),
                            Step(
                              title: const Text('Date'),
                              content: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        _selectedDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: colorScheme,
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (date != null) {
                                    setState(() => _selectedDate = date);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: _selectedDate != null
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        _selectedDate != null
                                            ? formatter.format(_selectedDate!)
                                            : 'Select Date',
                                        style: TextStyle(
                                          color: _selectedDate != null
                                              ? colorScheme.onSurface
                                              : colorScheme.onSurface
                                                  .withOpacity(0.5),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              isActive: _currentStep >= 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
