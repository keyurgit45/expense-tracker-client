import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/categories/data/datasources/category_remote_data_source.dart';
import '../features/categories/data/repositories/category_repository_impl.dart';
import '../features/categories/domain/repositories/category_repository.dart';
import '../features/categories/domain/services/category_service.dart';
import '../features/transactions/data/datasources/transaction_remote_data_source.dart';
import '../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import '../features/transactions/presentation/bloc/home_cubit.dart';
import '../features/transactions/presentation/bloc/transactions_list_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // Data sources
  getIt.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(getIt()),
  );

  // Services (registered before TransactionRemoteDataSource which depends on it)
  getIt.registerLazySingleton<CategoryService>(
    () => CategoryService(getIt<CategoryRepository>()),
  );
  
  getIt.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(getIt(), getIt<CategoryService>()),
  );

  // Repositories
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt()),
  );

  // Blocs/Cubits
  getIt.registerFactory(
    () => HomeCubit(getIt(), getIt<CategoryService>()),
  );
  getIt.registerFactory(
    () => TransactionsListCubit(getIt(), getIt<CategoryService>()),
  );
}