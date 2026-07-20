import 'package:flutter/material.dart';
import 'package:personal_tracker/models/expense.dart';
import 'package:personal_tracker/provider/expense_provider.dart';
import 'package:personal_tracker/widgets/edit_expense_sheet.dart';
import 'package:provider/provider.dart';

class ExpenseDetailSheet extends StatefulWidget {
  final Expense expense;
  const ExpenseDetailSheet({super.key, required this.expense});

  @override
  State<ExpenseDetailSheet> createState() => _ExpenseDetailSheetState();
}

class _ExpenseDetailSheetState extends State<ExpenseDetailSheet> {
  void _sheetEditExepnse(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditExpenseSheet(expense: widget.expense),
    );
  }

  Future<void> _deleteExpense(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result != true || !context.mounted) return;

    try {
      await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).deleteExpense(widget.expense.id!);

      if (!context.mounted) return;

      Navigator.of(context).pop(); // Close the detail sheet

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense Deleted'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: SnackBar(content: Text("Faield to deleted expense"))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final category = provider.getCategoryById(widget.expense.categoryId);
        return Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    category?.icon ?? "",
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                widget.expense.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '\$${widget.expense.amount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              _DetailRow(
                icon: Icons.category,
                label: 'Category',
                value: category?.name ?? "Unknown",
              ),
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value:
                    '${widget.expense.date.month}/ ${widget.expense.date.day}/${widget.expense.date.year}',
              ),
              if (widget.expense.description != null)
                _DetailRow(
                  icon: Icons.description,
                  label: 'Description',
                  value: widget.expense.description!,
                ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _sheetEditExepnse(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _sheetEditExepnse(context),
                      icon: const Icon(Icons.delete),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Spacer(),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
