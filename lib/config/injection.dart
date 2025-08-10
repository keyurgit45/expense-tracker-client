import 'package:another_telephony/telephony.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login.dart';
import '../features/auth/domain/usecases/logout.dart';
import '../features/auth/domain/usecases/sign_up.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/categories/data/datasources/category_remote_data_source.dart';
import '../features/categories/data/repositories/category_repository_impl.dart';
import '../features/categories/domain/repositories/category_repository.dart';
import '../features/categories/domain/services/category_service.dart';
import '../features/chat/data/datasources/chat_local_data_source.dart';
import '../features/chat/data/datasources/chat_remote_data_source.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/domain/usecases/create_chat_session.dart';
import '../features/chat/domain/usecases/send_message.dart';
import '../features/chat/presentation/bloc/chat_cubit.dart';
import '../features/sms/data/repositories/sms_repository_impl.dart';
import '../features/sms/domain/repositories/sms_repository.dart';
import '../features/sms/presentation/bloc/sms_cubit.dart';
import '../features/transactions/data/datasources/transaction_remote_data_source.dart';
import '../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import '../features/transactions/presentation/bloc/home_cubit.dart';
import '../features/transactions/presentation/bloc/transactions_list_cubit.dart';
import '../features/transactions/presentation/bloc/edit_transaction_cubit.dart';
import '../features/transactions/domain/usecases/update_transaction.dart';
import '../features/transactions/domain/usecases/create_transaction.dart';
import '../features/analytics/data/datasources/analytics_remote_data_source.dart';
import '../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../features/analytics/domain/repositories/analytics_repository.dart';
import '../features/analytics/domain/usecases/get_analytics_summary.dart';
import '../features/analytics/domain/usecases/get_category_analytics.dart';
import '../features/analytics/domain/usecases/get_spending_trends.dart';
import '../features/analytics/presentation/bloc/analytics_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
  getIt.registerLazySingleton<Telephony>(
    () => Telephony.instance,
  );
  getIt.registerLazySingleton<SharedPreferences>(
    () => sharedPreferences,
  );
  getIt.registerLazySingleton<Dio>(
    () => Dio()
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30),
  );
  getIt.registerLazySingleton<Uuid>(
    () => const Uuid(),
  );

  // Simple data sources (no dependencies on other project classes)
  getIt.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: getIt(),
      baseUrl: dotenv.env['CHAT_API_BASE_URL'] ?? 'http://localhost:8000',
    ),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      dio: getIt(),
      baseUrl: dotenv.env['CHAT_API_BASE_URL'] ?? 'http://localhost:8000',
    ),
  );
  getIt.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  // Repositories that only depend on data sources
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<SmsRepository>(
    () => SmsRepositoryImpl(telephony: getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );
  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remoteDataSource: getIt()),
  );
  
  // Services that depend on repositories
  getIt.registerLazySingleton<CategoryService>(
    () => CategoryService(getIt<CategoryRepository>()),
  );
  
  // Data sources that depend on services
  getIt.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(getIt(), getIt<CategoryService>()),
  );
  
  // Repositories that depend on complex data sources or other repositories
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      authRepository: getIt(),
      uuid: getIt(),
    ),
  );
  
  // Use cases
  getIt.registerLazySingleton<SendMessage>(
    () => SendMessage(getIt()),
  );
  getIt.registerLazySingleton<CreateChatSession>(
    () => CreateChatSession(getIt()),
  );
  getIt.registerLazySingleton<Login>(
    () => Login(getIt()),
  );
  getIt.registerLazySingleton<SignUp>(
    () => SignUp(getIt()),
  );
  getIt.registerLazySingleton<Logout>(
    () => Logout(getIt()),
  );
  getIt.registerLazySingleton<GetAnalyticsSummary>(
    () => GetAnalyticsSummary(getIt()),
  );
  getIt.registerLazySingleton<GetCategoryAnalytics>(
    () => GetCategoryAnalytics(getIt()),
  );
  getIt.registerLazySingleton<GetSpendingTrends>(
    () => GetSpendingTrends(getIt()),
  );
  getIt.registerLazySingleton<UpdateTransaction>(
    () => UpdateTransaction(getIt()),
  );
  getIt.registerLazySingleton<CreateTransaction>(
    () => CreateTransaction(getIt()),
  );

  // Blocs/Cubits
  getIt.registerFactory(
    () => HomeCubit(getIt(), getIt<CategoryService>()),
  );
  getIt.registerFactory(
    () => TransactionsListCubit(getIt(), getIt<CategoryService>()),
  );
  getIt.registerFactory(
    () => EditTransactionCubit(updateTransaction: getIt()),
  );
  getIt.registerFactory(
    () => SmsCubit(repository: getIt()),
  );
  getIt.registerFactory(
    () => ChatCubit(
      sendMessage: getIt(),
      createChatSession: getIt(),
      chatRepository: getIt(),
    ),
  );
  getIt.registerFactory(
    () => AuthCubit(
      login: getIt(),
      signUp: getIt(),
      logout: getIt(),
      authRepository: getIt(),
    ),
  );
  getIt.registerFactory(
    () => AnalyticsCubit(
      getAnalyticsSummary: getIt(),
      getCategoryAnalytics: getIt(),
      getSpendingTrends: getIt(),
    ),
  );
}