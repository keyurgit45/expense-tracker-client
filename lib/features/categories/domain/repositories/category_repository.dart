import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  
  Future<Either<Failure, List<Category>>> getActiveCategories();
  
  Future<Either<Failure, Category>> getCategoryById(String id);
  
  Future<Either<Failure, Category>> createCategory(Category category);
  
  Future<Either<Failure, Category>> updateCategory(Category category);
  
  Future<Either<Failure, void>> deleteCategory(String id);
}