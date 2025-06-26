import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;
  final Map<String, List<Category>> categoriesByParent;

  const CategoriesLoaded({
    required this.categories,
    required this.categoriesByParent,
  });

  @override
  List<Object?> get props => [categories, categoriesByParent];
}

class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}