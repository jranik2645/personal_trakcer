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
      final userid = currentUser?.id;
      if (userid == null) throw Exception('No authennticated user');
       
    } catch (e) {
      throw Exception('Failed to fetch expense :$e');
    }
  }
}
