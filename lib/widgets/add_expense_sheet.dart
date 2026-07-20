import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_tracker/models/expense.dart';
import 'package:personal_tracker/provider/expense_provider.dart';
import 'package:personal_tracker/utils/supabse_gVariable.dart';
import 'package:provider/provider.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titileController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void dispose() {
    _titileController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addExepense() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = false;
    });

    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    final expense = Expense(
      userId: supabase.auth.currentUser!.id,
      categoryId: _selectedCategoryId,
      title: _titileController.text,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      date: _selectedDate,
    );

    try {
      await provider.addExpense(expense);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Expense added suceessfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add Expense'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Consumer<ExpenseProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),

              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Expense',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context),
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _titileController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.title),
                                labelText: 'Title',
                              ),

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter  a title';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.attach_money),
                                labelText: 'Amount',
                              ),
                              keyboardType: TextInputType.number,

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an amount';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valied number';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedCategoryId,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: provider.category.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat.id, // Category ID
                                  child: Row(
                                    children: [
                                      Text(
                                        cat.icon ?? '📝',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(cat.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              },
                            ),

                            SizedBox(height: 16),

                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null)
                                  setState(() => _selectedDate = date);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_selectedDate),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description(optional)',
                                prefixIcon: Icon(Icons.description),
                              ),
                            ),

                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _addExepense,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6366F1),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                foregroundColor: Colors.white,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,

                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text('Add Expense'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
