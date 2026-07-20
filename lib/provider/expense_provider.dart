import 'package:flutter/material.dart';
import 'package:personal_tracker/models/category.dart';
import 'package:personal_tracker/models/expense.dart';
import 'package:personal_tracker/serivces/supabase_services.dart';

class ExpenseProvider extends ChangeNotifier {
  final SupabaseServices _supabaseServices = SupabaseServices();

  List<Expense> _expenses = [];
  List<Category> _categories = [];

  bool _isLoading = false;
  String? _error;

  List<Expense> get expense => _expenses;
  List<Category> get category => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get total expenses
  double get totalExpenses {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // get expense by category
  List<Expense> getExpensesByCategory(String categoryId) {
    return _expenses
        .where((expense) => expense.categoryId == categoryId)
        .toList();
  }

  // get category by Id
  Category? getCategoryById(String? categoryId) {
    if (categoryId == null) return null;
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.wait([loadCatgories(), loadExpenses()]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExpenses() async {
    try {
      _expenses = await _supabaseServices.getExpense();
      _expenses.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _error = 'Failed to load expense :$e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadCatgories() async {
    try {
      _categories = await _supabaseServices.getCategories();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to laod categories:$e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      final newExpense = await _supabaseServices.addExpense(expense);
      _expenses.insert(0, newExpense);
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add expense:$e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _supabaseServices.deletedExepnse(expenseId);
      _expenses.removeWhere((expense) => expense.id == expenseId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to deleted expense:$e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatedExpense(Expense expense) async {
    try {
      await _supabaseServices.updatedExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != 1) {
        _expenses[index] = expense;
        _expenses.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to updated expense:$e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _supabaseServices.addCategory(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to updated expense:$e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _supabaseServices.deleteCategory(categoryId);
      _categories.removeWhere((category) => category.id == categoryId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to updated expense:$e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatedCategory(Category category) async {
    try {
      await _supabaseServices.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _error = "Failed to updated category:$e";
      notifyListeners();
      rethrow;
    }
  }

  void clearData() {
    _expenses = [];
    _categories = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
