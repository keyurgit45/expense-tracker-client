import 'package:another_telephony/telephony.dart';
import 'package:dartz/dartz.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/sms_transaction.dart';
import '../../domain/repositories/sms_repository.dart';
import '../datasources/sms_parser.dart';
import '../models/sms_transaction_model.dart';

class SmsRepositoryImpl implements SmsRepository {
  final Telephony telephony;

  SmsRepositoryImpl({required this.telephony});

  @override
  Future<Either<Failure, List<SmsTransaction>>> getAllSmsTransactions() async {
    try {
      // Check permission first
      final hasPermission = await _checkSmsPermission();
      if (!hasPermission) {
        return Left(CacheFailure(message: 'SMS permission not granted'));
      }

      // Get all SMS messages
      final messages = await telephony.getInboxSms(
        columns: [
          SmsColumn.ID,
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.DATE,
        ],
        sortOrder: [
          OrderBy(SmsColumn.DATE, sort: Sort.DESC),
        ],
      );

      // Convert to SmsTransactionModel and parse
      final smsTransactions = messages.map((sms) {
        final model = SmsTransactionModel.fromSms(
          id: sms.id?.toString() ?? '',
          address: sms.address ?? '',
          body: sms.body ?? '',
          dateTime: sms.date,
        );
        
        // Parse the SMS to extract transaction details
        return SmsParser.parseTransaction(model);
      }).where((sms) => sms.isParsed).toList();

      return Right(smsTransactions);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SmsTransaction>>> getAllSmsMessages() async {
    try {
      // Check permission first
      final hasPermission = await _checkSmsPermission();
      if (!hasPermission) {
        return const Left(CacheFailure(message: 'SMS permission not granted'));
      }

      // Get all SMS messages
      final messages = await telephony.getInboxSms(
        columns: [
          SmsColumn.ID,
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.DATE,
        ],
        sortOrder: [
          OrderBy(SmsColumn.DATE, sort: Sort.DESC),
        ],
      );

      // Convert to SmsTransactionModel and parse ALL messages
      final smsTransactions = messages.map((sms) {
        final model = SmsTransactionModel.fromSms(
          id: sms.id?.toString() ?? '',
          address: sms.address ?? '',
          body: sms.body ?? '',
          dateTime: sms.date,
        );
        
        // Parse the SMS to extract transaction details
        return SmsParser.parseTransaction(model);
      }).toList(); // Return all messages, not just parsed ones

      return Right(smsTransactions);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestSmsPermission() async {
    try {
      final status = await Permission.sms.request();
      return Right(status.isGranted);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<bool> _checkSmsPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }
}