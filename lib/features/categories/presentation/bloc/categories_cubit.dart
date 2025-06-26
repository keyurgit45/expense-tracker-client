import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/services/category_service.dart';
import '../../domain/entities/category.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoryService _categoryService;

  CategoriesCubit({
    required CategoryService categoryService,
  })  : _categoryService = categoryService,
        super(CategoriesInitial());

  Future<void> loadCategories() async {
    emit(CategoriesLoading());
    try {
      final categories = await _categoryService.getCategories();
      
      // Group categories by parent
      final categoriesByParent = <String, List<Category>>{};
      
      // First, get all parent categories (where parentCategoryId is null)
      final parentCategories = categories
          .where((cat) => cat.parentCategoryId == null)
          .toList();
      
      // Then group child categories by their parent
      for (final category in categories) {
        if (category.parentCategoryId != null) {
          categoriesByParent.putIfAbsent(
            category.parentCategoryId!,
            () => <Category>[],
          ).add(category);
        }
      }
      
      emit(CategoriesLoaded(
        categories: parentCategories,
        categoriesByParent: categoriesByParent,
      ));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}