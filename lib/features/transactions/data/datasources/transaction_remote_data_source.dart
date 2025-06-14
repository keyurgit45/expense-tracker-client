import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/account_summary_model.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getLatestTransactions({int limit = 10});
  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });
  Future<TransactionModel> getTransactionById(String id);
  Future<AccountSummaryModel> getAccountSummary();
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Stream<List<TransactionModel>> watchLatestTransactions({int limit = 10});
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final SupabaseClient _supabaseClient;

  TransactionRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<TransactionModel>> getLatestTransactions({int limit = 10}) async {
    try {
      final response = await _supabaseClient
          .from('transactions')
          .select()
          .order('date', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch transactions: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      // Build the query dynamically
      final queryBuilder = _supabaseClient.from('transactions').select();
      dynamic query = queryBuilder;

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String());
      }

      // Apply order
      query = query.order('date', ascending: false);
      
      // Apply range or limit
      if (offset != null && limit != null) {
        query = query.range(offset, offset + limit - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch transactions: $e');
    }
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final response = await _supabaseClient
          .from('transactions')
          .select()
          .eq('transaction_id', id)
          .single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch transaction: $e');
    }
  }

  @override
  Future<AccountSummaryModel> getAccountSummary() async {
    try {
      // For now, we'll calculate this from transactions
      // In a real app, this might come from a view or stored procedure
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
      final endOfLastMonth = DateTime(now.year, now.month, 0);

      // Get current month transactions
      final currentMonthResponse = await _supabaseClient
          .from('transactions')
          .select('amount')
          .gte('date', startOfMonth.toIso8601String());

      // Get last month transactions
      final lastMonthResponse = await _supabaseClient
          .from('transactions')
          .select('amount')
          .gte('date', startOfLastMonth.toIso8601String())
          .lte('date', endOfLastMonth.toIso8601String());

      // Calculate totals
      double currentIncome = 0;
      double currentExpense = 0;
      double lastIncome = 0;
      double lastExpense = 0;

      for (final transaction in currentMonthResponse as List) {
        final amount = (transaction['amount'] as num).toDouble();
        if (amount >= 0) {
          currentIncome += amount;
        } else {
          currentExpense += amount.abs();
        }
      }

      for (final transaction in lastMonthResponse as List) {
        final amount = (transaction['amount'] as num).toDouble();
        if (amount >= 0) {
          lastIncome += amount;
        } else {
          lastExpense += amount.abs();
        }
      }

      // Calculate percentages
      final incomeChange = lastIncome > 0
          ? ((currentIncome - lastIncome) / lastIncome) * 100
          : 0.0;
      final expenseChange = lastExpense > 0
          ? ((currentExpense - lastExpense) / lastExpense) * 100
          : 0.0;

      return AccountSummaryModel(
        totalBalance: currentIncome - currentExpense,
        totalIncome: currentIncome,
        totalExpense: currentExpense,
        incomeChangePercentage: incomeChange,
        expenseChangePercentage: expenseChange,
        accountNumber: 'PL4 76458 645897 86457', // Mock for now
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch account summary: $e');
    }
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    try {
      final response = await _supabaseClient
          .from('transactions')
          .insert(transaction.toJson())
          .select()
          .single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to create transaction: $e');
    }
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    try {
      final response = await _supabaseClient
          .from('transactions')
          .update(transaction.toJson())
          .eq('transaction_id', transaction.id)
          .select()
          .single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _supabaseClient
          .from('transactions')
          .delete()
          .eq('transaction_id', id);
    } catch (e) {
      throw ServerException(message: 'Failed to delete transaction: $e');
    }
  }

  @override
  Stream<List<TransactionModel>> watchLatestTransactions({int limit = 10}) {
    return _supabaseClient
        .from('transactions')
        .stream(primaryKey: ['transaction_id'])
        .order('date', ascending: false)
        .limit(limit)
        .map((data) => data.map((json) => TransactionModel.fromJson(json)).toList());
  }
}