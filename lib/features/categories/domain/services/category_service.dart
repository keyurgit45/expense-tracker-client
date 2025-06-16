import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CategoryService {
  final CategoryRepository _categoryRepository;
  List<Category>? _cachedCategories;
  DateTime? _lastFetchTime;
  static const _cacheValidityDuration = Duration(hours: 1);

  CategoryService(this._categoryRepository);

  /// Gets all categories with caching
  Future<List<Category>> getCategories({bool forceRefresh = false}) async {
    // Check if we need to refresh cache
    if (!forceRefresh && 
        _cachedCategories != null && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidityDuration) {
      return _cachedCategories!;
    }

    // Fetch fresh categories
    final result = await _categoryRepository.getCategories();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (categories) {
        _cachedCategories = categories;
        _lastFetchTime = DateTime.now();
        return categories;
      },
    );
  }

  /// Get category by ID from cache or fetch if needed
  Category? getCategoryById(String id) {
    return _cachedCategories?.firstWhere(
      (category) => category.id == id,
      orElse: () => const Category(id: '', name: 'Other'),
    );
  }

  /// Get category name by ID
  String getCategoryName(String? categoryId) {
    if (categoryId == null || _cachedCategories == null) {
      return 'Other';
    }
    
    final category = getCategoryById(categoryId);
    return category?.name ?? 'Other';
  }

  /// Clear the cache
  void clearCache() {
    _cachedCategories = null;
    _lastFetchTime = null;
  }

  /// Preload categories for app startup
  Future<void> preloadCategories() async {
    await getCategories();
  }
}