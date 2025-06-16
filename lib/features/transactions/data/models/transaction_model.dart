import '../../domain/entities/transaction.dart';

class TransactionModel {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String? categoryId;
  final String? categoryName;
  final String? notes;
  final bool isRecurring;

  const TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    this.categoryId,
    this.categoryName,
    this.notes,
    this.isRecurring = false,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['transaction_id'] as String,
      description: json['merchant'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      categoryId: json['category_id'] as String?,
      categoryName: json['categories'] != null ? json['categories']['name'] as String? : null,
      notes: json['notes'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': id,
      'merchant': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'notes': notes,
      'is_recurring': isRecurring,
    };
  }

  Transaction toEntity() {
    // Determine type based on amount (positive = income, negative = expense)
    final type = amount >= 0 ? TransactionType.income : TransactionType.expense;
    
    // Determine tag based on description or default to other
    final tag = _determineTag(description);
    
    return Transaction(
      id: id,
      description: description,
      amount: amount.abs(), // Store absolute value
      type: type,
      tag: tag,
      date: date,
      categoryId: categoryId,
      categoryName: categoryName,
      notes: notes,
      isRecurring: isRecurring,
    );
  }

  factory TransactionModel.fromEntity(Transaction entity) {
    // Store negative amount for expenses
    final amount = entity.type == TransactionType.expense 
        ? -entity.amount 
        : entity.amount;
    
    return TransactionModel(
      id: entity.id,
      description: entity.description,
      amount: amount,
      date: entity.date,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      notes: entity.notes,
      isRecurring: entity.isRecurring,
    );
  }

  TransactionTag _determineTag(String description) {
    final lowerDesc = description.toLowerCase();
    if (lowerDesc.contains('fee')) return TransactionTag.fee;
    if (lowerDesc.contains('sale')) return TransactionTag.sale;
    if (lowerDesc.contains('refund')) return TransactionTag.refund;
    return TransactionTag.other;
  }
}