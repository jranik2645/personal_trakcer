import 'package:flutter/material.dart';
import 'package:personal_tracker/provider/expense_provider.dart';
import 'package:personal_tracker/screen/dashboard_tab.dart';
import 'package:personal_tracker/screen/expense_tab.dart';
import 'package:personal_tracker/serivces/supabase_services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabaseSerivce = SupabaseServices();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Provider.of<ExpenseProvider>(context, listen: false).loadData();
  }

  Future<void> _logOut() async {
    try {
      await _supabaseSerivce.signOut();

      if (!mounted) return;
      Provider.of<ExpenseProvider>(context, listen: false).clearData();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense_Tracker"),
        actions: [IconButton(onPressed: _logOut, icon: Icon(Icons.logout))],
        bottom: TabBar(
          labelColor: Color(0xFF6366F1),
          indicatorColor: Color(0xFF6366F1),
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Expense'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [DashboardTab(), ExpenseTab()],
      ),
    );
  }
}
