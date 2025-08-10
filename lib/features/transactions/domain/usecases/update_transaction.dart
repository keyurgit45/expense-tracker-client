import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction implements UseCase<Transaction, UpdateTransactionParams> {
  final TransactionRepository repository;

  UpdateTransaction(this.repository);

  @override
  Future<Either<Failure, Transaction>> call(UpdateTransactionParams params) async {
    return await repository.updateTransaction(params.transaction);
  }
}

class UpdateTransactionParams {
  final Transaction transaction;

  UpdateTransactionParams({required this.transaction});
}