import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:personal_tracker/provider/expense_provider.dart';
import 'package:provider/provider.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        final now = DateTime.now();
        final thisMonth = provider.getExpensesByDateRange(
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 0),
        );
        final thisWeek = provider.getExpensesByDateRange(
          now.subtract(Duration(days: now.weekday - 1)),
          now,
        );
        final today = provider.getExpensesByDateRange(
          DateTime(now.year, now.month, now.day),
          DateTime(now.year, now.month, now.day, 23, 59),
        );

        final totalMonth = thisMonth.fold(0.0, (sum, e) => sum + e.amount);
        final totalWeek = thisMonth.fold(0.0, (sum, e) => sum + e.amount);
        final totalToday = thisMonth.fold(0.0, (sum, e) => sum + e.amount);

        Map<String, double> categoryTotals = {};

        for (var expense in provider.expense) {
          final cat = provider.getCategoryById(expense.categoryId);
          final catName = cat?.name ?? 'Uncategorized';
          categoryTotals[catName] =
              (categoryTotals[catName] ?? 0) + expense.amount;
        }
        return RefreshIndicator(
          onRefresh: () => provider.loadData(),
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 48, 50, 159),
                      Color(0xFF6366F1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF63366F1).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Balance',

                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "\$${provider.totalExpenses.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${provider.expense.length} transactions",

                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Toady',
                      amount: totalToday,
                      icon: Icons.today,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'This Week',
                      amount: totalWeek,
                      icon: Icons.date_range,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 12),
                ],
              ),
              SizedBox(height: 12),
              _StatCard(
                title: 'This Month',
                amount: totalMonth,
                icon: Icons.calendar_month,
                color: Colors.orange,
                wide: true,
              ),
              SizedBox(height: 24),
              if (categoryTotals.isNotEmpty) ...[
                Text(
                  'Cateory',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Container(
                  height: 200,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: categoryTotals.entries.map((entry) {
                        final percentage =
                            (entry.value / provider.totalExpenses) * 100;
                        return PieChartSectionData(
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                SizedBox(height: 16),
                ...categoryTotals.entries.map((entry) {
                  final cat = provider.category.firstWhere(
                    (c) => c.name == entry,
                    orElse: () => provider.category.first,
                  );
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          cat.icon ?? '📝',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.key)),
                        Text(
                          '\$${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool wide;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (!wide)
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          SizedBox(height: 4),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
