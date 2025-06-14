import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/transactions/presentation/pages/transactions_list_page.dart';

class AppRouter {
  static const String home = '/';
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transactions/:id';
  static const String addTransaction = '/transactions/add';
  static const String categories = '/categories';
  static const String analytics = '/analytics';
  static const String settings = '/settings';

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
              return Scaffold(
                body: Center(child: Text('Transaction Detail: $id')),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: categories,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Categories')),
        ),
      ),
      GoRoute(
        path: analytics,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Analytics')),
        ),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Settings')),
        ),
      ),
    ],
  );
}