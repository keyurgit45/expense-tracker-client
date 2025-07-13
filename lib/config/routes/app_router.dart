import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/color_constants.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/transactions/presentation/pages/transactions_list_page.dart';
import '../../features/transactions/presentation/pages/transaction_details_wrapper.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/sms/presentation/pages/sms_transactions_page.dart';
import '../../features/sms/presentation/bloc/sms_cubit.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/chat_sessions_page.dart';
import '../../features/chat/presentation/bloc/chat_cubit.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
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
              final id = state.pathParameters['id']!;
              // TODO: Implement edit transaction page
              return Scaffold(
                backgroundColor: ColorConstants.bgPrimary,
                appBar: AppBar(
                  backgroundColor: ColorConstants.bgPrimary,
                  title: Text('Edit Transaction', 
                    style: GoogleFonts.inter(color: ColorConstants.textPrimary),
                  ),
                  iconTheme: const IconThemeData(color: ColorConstants.textPrimary),
                ),
                body: Center(
                  child: Text(
                    'Edit Transaction: $id\n(Coming Soon)', 
                    style: GoogleFonts.inter(
                      color: ColorConstants.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
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
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Analytics')),
        ),
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