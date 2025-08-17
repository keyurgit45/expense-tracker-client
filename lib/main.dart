import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/injection.dart';
import 'config/routes/app_router.dart';
import 'config/supabase_config.dart';
import 'config/theme/app_theme.dart';
import 'features/categories/domain/services/category_service.dart';
import 'features/transactions/presentation/bloc/transactions_list_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // In production, use a proper logging framework
    debugPrint('Error loading .env file: $e');
  }

  // Validate Supabase configuration
  SupabaseConfig.validateConfig();

  // Initialize Supabase
  if (SupabaseConfig.supabaseUrl.isNotEmpty &&
      SupabaseConfig.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  // Configure dependencies
  await configureDependencies();

  // Preload categories for optimized performance
  try {
    final categoryService = getIt<CategoryService>();
    await categoryService.preloadCategories();
  } catch (e) {
    debugPrint('Error preloading categories: $e');
  }

  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransactionsListCubit>(),
      child: MaterialApp.router(
        title: 'Expenses',
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
