import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> getCategoryById(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final SupabaseClient _supabaseClient;

  CategoryRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _supabaseClient
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch categories: $e');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await _supabaseClient
          .from('categories')
          .select()
          .eq('category_id', id)
          .single();

      return CategoryModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch category: $e');
    }
  }
}