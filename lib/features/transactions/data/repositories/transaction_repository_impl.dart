import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/account_summary.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Transaction>>> getLatestTransactions({
    int limit = 10,
  }) async {
    try {
      final transactionModels = await remoteDataSource.getLatestTransactions(
        limit: limit,
      );
      final transactions = transactionModels
          .map((model) => model.toEntity())
          .toList();
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      final transactionModels = await remoteDataSource.getTransactions(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );
      final transactions = transactionModels
          .map((model) => model.toEntity())
          .toList();
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    try {
      final transactionModel = await remoteDataSource.getTransactionById(id);
      return Right(transactionModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountSummary>> getAccountSummary() async {
    try {
      final summaryModel = await remoteDataSource.getAccountSummary();
      return Right(summaryModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> createTransaction(
    Transaction transaction,
  ) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      final createdModel = await remoteDataSource.createTransaction(
        transactionModel,
      );
      return Right(createdModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
    Transaction transaction,
  ) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      final updatedModel = await remoteDataSource.updateTransaction(
        transactionModel,
      );
      return Right(updatedModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await remoteDataSource.deleteTransaction(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Transaction>>> watchLatestTransactions({
    int limit = 10,
  }) {
    try {
      return remoteDataSource
          .watchLatestTransactions(limit: limit)
          .map((transactionModels) {
        final transactions = transactionModels
            .map((model) => model.toEntity())
            .toList();
        return Right<Failure, List<Transaction>>(transactions);
      });
    } catch (e) {
      return Stream.value(
        Left<Failure, List<Transaction>>(
          UnknownFailure(message: e.toString()),
        ),
      );
    }
  }
}