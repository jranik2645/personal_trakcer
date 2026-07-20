import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_tracker/models/expense.dart';
import 'package:personal_tracker/provider/expense_provider.dart';
import 'package:provider/provider.dart';

class EditExpenseSheet extends StatefulWidget {
  final Expense expense;
  const EditExpenseSheet({super.key, required this.expense});

  @override
  State<EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _EditExpenseSheetState extends State<EditExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selecteDate;
  late String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _descriptionController = TextEditingController(
      text: widget.expense.amount.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.expense.description ?? '',
    );
    _selecteDate = widget.expense.date;
    _selectedCategoryId = widget.expense.categoryId;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
  }

  Future<void> updateExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final updatedExpense = widget.expense.copyWith(
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      date: _selecteDate,
      categoryId: _selectedCategoryId,
    );

    try {
      await provider.updatedExpense(updatedExpense);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Exepnse upated successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to  updated expense. pelase try again"),
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
                          'Edit Expense',
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
                              controller: _titleController,
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
                                  initialDate: _selecteDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null)
                                  setState(() => _selecteDate = date);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_selecteDate),
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
                              onPressed: _isLoading ? null : updateExpense,
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
                                  : Text('Updated Expense'),
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
