import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sms_transaction.dart';

abstract class SmsRepository {
  Future<Either<Failure, List<SmsTransaction>>> getAllSmsTransactions();
  Future<Either<Failure, List<SmsTransaction>>> getAllSmsMessages(); // For export
  Future<Either<Failure, bool>> requestSmsPermission();
}