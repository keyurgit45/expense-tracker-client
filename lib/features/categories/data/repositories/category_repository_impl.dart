import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await _remoteDataSource.getCategories();
      return Right(categories.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String id) async {
    try {
      final category = await _remoteDataSource.getCategoryById(id);
      return Right(category.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getActiveCategories() async {
    try {
      final categories = await _remoteDataSource.getCategories();
      final activeCategories = categories
          .where((category) => category.isActive)
          .map((model) => model.toEntity())
          .toList();
      return Right(activeCategories);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory(Category category) async {
    // Not implemented for now as we don't need this functionality
    return const Left(ServerFailure(message: 'Create category not implemented'));
  }

  @override
  Future<Either<Failure, Category>> updateCategory(Category category) async {
    // Not implemented for now as we don't need this functionality
    return const Left(ServerFailure(message: 'Update category not implemented'));
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    // Not implemented for now as we don't need this functionality
    return const Left(ServerFailure(message: 'Delete category not implemented'));
  }
}