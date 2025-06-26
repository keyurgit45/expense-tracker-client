import 'package:equatable/equatable.dart';

class SmsTransaction extends Equatable {
  final String id;
  final String senderAddress;
  final String body;
  final DateTime date;
  final double? amount;
  final TransactionType? transactionType;
  final String? merchant;
  final String? reference;
  final String? bankName;
  final String? paymentMethod;
  
  const SmsTransaction({
    required this.id,
    required this.senderAddress,
    required this.body,
    required this.date,
    this.amount,
    this.transactionType,
    this.merchant,
    this.reference,
    this.bankName,
    this.paymentMethod,
  });

  bool get isParsed => amount != null && transactionType != null;

  @override
  List<Object?> get props => [
        id,
        senderAddress,
        body,
        date,
        amount,
        transactionType,
        merchant,
        reference,
        bankName,
        paymentMethod,
      ];
}

enum TransactionType { credit, debit }