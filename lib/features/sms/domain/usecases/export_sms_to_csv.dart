import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../entities/sms_transaction.dart';

class ExportSmsToCsv {
  static Future<void> exportToCSV(List<SmsTransaction> transactions) async {
    // Define CSV headers
    final headers = [
      'timestamp',
      'sender',
      'message',
      'is_bank_transaction',
      'transaction_type',
      'amount',
      'merchant',
      'payment_method',
      'bank_name',
      'reference',
      'confidence_score',
      'needs_review',
    ];

    // Create rows
    final rows = <List<dynamic>>[headers];
    
    for (final transaction in transactions) {
      final row = [
        transaction.date.toIso8601String(),
        transaction.senderAddress,
        transaction.body.replaceAll('\n', ' '), // Replace newlines for CSV
        transaction.isParsed,
        transaction.transactionType?.toString().split('.').last ?? '',
        transaction.amount ?? '',
        transaction.merchant ?? '',
        transaction.paymentMethod ?? '',
        transaction.bankName ?? '',
        transaction.reference ?? '',
        transaction.isParsed ? 0.9 : 0.3, // Simple confidence score
        !transaction.isParsed, // Needs review if not parsed
      ];
      rows.add(row);
    }

    // Convert to CSV
    final csv = const ListToCsvConverter().convert(rows);

    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/sms_training_data_$timestamp.csv');
    await file.writeAsString(csv);

    // Share the file
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'SMS Training Data',
      text: 'SMS training data export with ${transactions.length} messages',
    );
  }
}