import 'package:personal_tracker/models/expense.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';

class SupabaseServices {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      if (response.user == null) {
        await _createDefaultCategories(response.user!.id);
      }
      return response;
    } catch (e) {
      throw Exception('Sign up failed:$e');
    }
  }

  Future<void> _createDefaultCategories(String userId) async {
    try {
      final defaultCategories = [
        {'user_id': userId, 'name': 'Food', 'icon': '🍔', 'color': '#FF5733'},
        {
          'user_id': userId,
          'name': 'Transport',
          'icon': '🚗',
          'color': '#33C1FF',
        },
        {
          'user_id': userId,
          'name': 'Entertainment',
          'icon': '🎬',
          'color': '#9D33FF',
        },
        {
          'user_id': userId,
          'name': 'Shopping',
          'icon': '🛍️',
          'color': '#FF33A8',
        },
        {'user_id': userId, 'name': 'Bills', 'icon': '💡', 'color': '#33FF57'},
        {'user_id': userId, 'name': 'Health', 'icon': '🏥', 'color': '#FF8C33'},
      ];

      final response = await _client
          .from('categories')
          .insert(defaultCategories);
    } catch (e) {
      print('Error creating default categories: $e');
    }
  }

  // Sign In
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Get categories
  Future<List<Category>> getCategories() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final response = await _client
          .from('categories')
          .select()
          .eq('user_id', userId);
      return (response as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories:$e');
    }
  }

  // add category

  Future<void> addCategory(Category category) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final response = await _client
          .from('categories')
          .insert(category.toJson())
          .select()
          .single();
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  //update category
  Future<void> updateCategory(Category category) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final response = await _client
          .from('categories')
          .update(category.toJson())
          .eq('id', category.id)
          .select()
          .single();
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  //delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final response = await _client
          .from('categories')
          .delete()
          .eq('id', categoryId);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<List<Expense>> getExpense() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('No authenticated user');

      final response = await _client
          .from('expenses')
          .select()
          .eq('user_id', userId);

      return (response as List).map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch expense :$e');
    }
  }

  // add expense
  Future<Expense> addExpense(Expense expense) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('No authenticted user');

      final response = await _client
          .from('expense')
          .insert(expense.toJson())
          .select()
          .single();
      return Expense.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add expense :$e');
    }
  }

  // updated expense
  Future<void> updatedExpense(Expense expense) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('No authenticated user');

      await _client
          .from('expense')
          .update(expense.toJson())
          .eq('id', expense.id!)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to updated expense :$e');
    }
  }

  //deleted expense
  Future<void> deletedExepnse(String expenseId) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('No authenticated user');
      await _client
          .from('expense')
          .delete()
          .eq('id', expenseId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to deleted exepnse:$e');
    }
  }

  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime enDate,
  ) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('No authenticated user');

      final response = await _client
          .from('expense')
          .select()
          .eq('user_id', userId)
          .gt('date', startDate.toIso8601String().split('T')[0])
          .lte('date', enDate.toIso8601String().split('T')[0])
          .order('date', ascending: false);

      return (response as List).map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch expenses by date range:$e');
    }
  }
}
