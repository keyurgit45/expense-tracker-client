import 'package:equatable/equatable.dart';
import '../../domain/entities/sms_transaction.dart';

abstract class SmsState extends Equatable {
  const SmsState();

  @override
  List<Object?> get props => [];
}

class SmsInitial extends SmsState {}

class SmsLoading extends SmsState {}

class SmsLoaded extends SmsState {
  final List<SmsTransaction> transactions;
  final TransactionType? filterType;

  const SmsLoaded({
    required this.transactions,
    this.filterType,
  });

  List<SmsTransaction> get filteredTransactions {
    if (filterType == null) return transactions;
    return transactions
        .where((tx) => tx.transactionType == filterType)
        .toList();
  }

  @override
  List<Object?> get props => [transactions, filterType];
}

class SmsError extends SmsState {
  final String message;

  const SmsError({required this.message});

  @override
  List<Object> get props => [message];
}

class SmsPermissionDenied extends SmsState {}