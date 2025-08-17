import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/transactions/presentation/pages/transactions_list_page.dart';
import '../../features/transactions/presentation/pages/transaction_details_wrapper.dart';
import '../../features/transactions/presentation/pages/edit_transaction_page.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/sms/presentation/pages/sms_transactions_page.dart';
import '../../features/sms/presentation/bloc/sms_cubit.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/chat_sessions_page.dart';
import '../../features/chat/presentation/bloc/chat_cubit.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/sms/presentation/pages/add_transaction_from_sms_page.dart';
import '../../features/sms/domain/entities/sms_transaction.dart';
import '../../features/transactions/presentation/bloc/home_cubit.dart';
import '../injection.dart';

class AppRouter {
  static const String home = '/';
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transactions/:id';
  static const String addTransaction = '/transactions/add';
  static const String categories = '/categories';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
  static const String sms = '/sms';
  static const String chat = '/chat';
  static const String chatSessions = '/chat/sessions';
  static const String chatDetail = '/chat/:sessionId';

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const TransactionsPage(),
      ),
      GoRoute(
        path: transactions,
        builder: (context, state) => const TransactionsListPage(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Add Transaction')),
            ),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TransactionDetailsWrapper(transactionId: id);
            },
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) {
              final transaction = state.extra as Transaction;
              return EditTransactionPage(transaction: transaction);
            },
          ),
        ],
      ),
      GoRoute(
        path: categories,
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: analytics,
        builder: (context, state) => const AnalyticsPage(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: sms,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<SmsCubit>(),
          child: const SmsTransactionsPage(),
        ),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) {
              final smsTransaction = state.extra as SmsTransaction;
              return BlocProvider(
                create: (_) => getIt<HomeCubit>(),
                child:
                    AddTransactionFromSmsPage(smsTransaction: smsTransaction),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: chat,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<ChatCubit>(),
          child: const ChatPage(),
        ),
        routes: [
          GoRoute(
            path: 'sessions',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<ChatCubit>(),
              child: const ChatSessionsPage(),
            ),
          ),
          GoRoute(
            path: ':sessionId',
            builder: (context, state) {
              final sessionId = state.pathParameters['sessionId']!;
              return BlocProvider(
                create: (_) => getIt<ChatCubit>(),
                child: ChatPage(sessionId: sessionId),
              );
            },
          ),
        ],
      ),
    ],
  );
}
