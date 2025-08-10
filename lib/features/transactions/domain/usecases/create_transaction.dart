import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class CreateTransaction implements UseCase<Transaction, CreateTransactionParams> {
  final TransactionRepository repository;

  CreateTransaction(this.repository);

  @override
  Future<Either<Failure, Transaction>> call(CreateTransactionParams params) async {
    return await repository.createTransaction(params.transaction);
  }
}

class CreateTransactionParams {
  final Transaction transaction;

  CreateTransactionParams({required this.transaction});
}