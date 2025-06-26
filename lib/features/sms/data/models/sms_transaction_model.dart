import '../../domain/entities/sms_transaction.dart';

class SmsTransactionModel extends SmsTransaction {
  const SmsTransactionModel({
    required String id,
    required String senderAddress,
    required String body,
    required DateTime date,
    double? amount,
    TransactionType? transactionType,
    String? merchant,
    String? reference,
    String? bankName,
    String? paymentMethod,
  }) : super(
          id: id,
          senderAddress: senderAddress,
          body: body,
          date: date,
          amount: amount,
          transactionType: transactionType,
          merchant: merchant,
          reference: reference,
          bankName: bankName,
          paymentMethod: paymentMethod,
        );

  factory SmsTransactionModel.fromSms({
    required String id,
    required String address,
    required String body,
    required int? dateTime,
  }) {
    final date = dateTime != null
        ? DateTime.fromMillisecondsSinceEpoch(dateTime)
        : DateTime.now();
    
    return SmsTransactionModel(
      id: id,
      senderAddress: address,
      body: body,
      date: date,
    );
  }

  SmsTransactionModel copyWith({
    String? id,
    String? senderAddress,
    String? body,
    DateTime? date,
    double? amount,
    TransactionType? transactionType,
    String? merchant,
    String? reference,
    String? bankName,
    String? paymentMethod,
  }) {
    return SmsTransactionModel(
      id: id ?? this.id,
      senderAddress: senderAddress ?? this.senderAddress,
      body: body ?? this.body,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      transactionType: transactionType ?? this.transactionType,
      merchant: merchant ?? this.merchant,
      reference: reference ?? this.reference,
      bankName: bankName ?? this.bankName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}