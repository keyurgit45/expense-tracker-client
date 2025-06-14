import '../../domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final bool isActive;
  final String? parentCategoryId;

  const CategoryModel({
    required this.id,
    required this.name,
    this.isActive = true,
    this.parentCategoryId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['category_id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      parentCategoryId: json['parent_category_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': id,
      'name': name,
      'is_active': isActive,
      'parent_category_id': parentCategoryId,
    };
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      isActive: isActive,
      parentCategoryId: parentCategoryId,
    );
  }

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      isActive: entity.isActive,
      parentCategoryId: entity.parentCategoryId,
    );
  }
}