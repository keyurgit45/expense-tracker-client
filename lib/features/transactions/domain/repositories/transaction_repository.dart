import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/account_summary.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getLatestTransactions({
    int limit = 10,
  });

  Future<Either<Failure, List<Transaction>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, Transaction>> getTransactionById(String id);

  Future<Either<Failure, AccountSummary>> getAccountSummary();

  Future<Either<Failure, Transaction>> createTransaction(Transaction transaction);

  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction);

  Future<Either<Failure, void>> deleteTransaction(String id);

  Stream<Either<Failure, List<Transaction>>> watchLatestTransactions({
    int limit = 10,
  });
}