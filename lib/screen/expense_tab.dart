import 'package:flutter/material.dart';
import 'package:personal_tracker/models/expense.dart';
import 'package:personal_tracker/provider/expense_provider.dart';
import 'package:personal_tracker/screen/expense_detail_sheet.dart';
import 'package:personal_tracker/widgets/add_expense_sheet.dart';
import 'package:provider/provider.dart';

class ExpenseTab extends StatefulWidget {
  const ExpenseTab({super.key});

  @override
  State<ExpenseTab> createState() => _ExpenseTabState();
}

class _ExpenseTabState extends State<ExpenseTab> {
  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddExpenseSheet(),
    );
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ExpenseDetailSheet(expense: expense),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.expense.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("No expense added yet."),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showAddExpenseSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6366F1),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Add Exepense"),
                ),
              ],
            ),
          );
        }
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => provider.loadData(),
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: provider.expense.length,

                itemBuilder: (context, index) {
                  final expense = provider.expense[index];
                  final categroy = provider.getCategoryById(expense.categoryId);
                  return Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          categroy?.icon ?? '',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(
                        expense.title,
                        style: TextStyle(fontSize: 23),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(categroy?.name ?? 'Uncatgrorized'),
                          Text(
                            '${expense.date.month}/${expense.date.day}/${expense.date.year}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),

                      trailing: Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF366F1),
                        ),
                      ),
                      onTap: () => _showExpenseDetails(context, expense),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,

              child: FloatingActionButton.extended(
                onPressed: () => _showAddExpenseSheet(context),
                icon: Icon(Icons.add),
                label: Text('Add Exepense'),
              ),
            ),
          ],
        );
      },
    );
  }
}
