import '../models/sms_transaction_model.dart';
import '../../domain/entities/sms_transaction.dart';

class SmsParser {
  // TODO: Currently optimized for HDFC Bank messages. Generalize for other banks in the future.
  static final RegExp _amountRegex = RegExp(
    r'(?:inr|rs|₹)\.?\s*([0-9,]+(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );
  
  static final RegExp _alternativeAmountRegex = RegExp(
    r'([0-9,]+(?:\.[0-9]{1,2})?)\s*(?:inr|rs|₹)',
    caseSensitive: false,
  );
  
  // HDFC specific patterns
  static final RegExp _hdfcSentAmountRegex = RegExp(
    r'Sent\s+Rs\.([0-9,]+(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );
  
  static final RegExp _hdfcSpentAmountRegex = RegExp(
    r'Spent\s+Rs\.([0-9,]+(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );

  static final Map<String, String> _bankIdentifiers = {
    'HDFC': 'HDFC Bank',
    'HDFCBK': 'HDFC Bank',
    'ICICI': 'ICICI Bank',
    'ICICIB': 'ICICI Bank',
    'SBI': 'State Bank of India',
    'SBIINB': 'State Bank of India',
    'AXIS': 'Axis Bank',
    'AXISBK': 'Axis Bank',
    'KOTAK': 'Kotak Bank',
    'PNB': 'Punjab National Bank',
    'CANARA': 'Canara Bank',
    'CANARABANK': 'Canara Bank',
    'BOB': 'Bank of Baroda',
    'UNION': 'Union Bank',
    'IDBI': 'IDBI Bank',
    'YES': 'Yes Bank',
    'INDUSIND': 'IndusInd Bank',
  };

  static SmsTransactionModel parseTransaction(SmsTransactionModel sms) {
    // Check if it's a bank transaction
    if (!_isBankTransaction(sms.body)) {
      return sms;
    }

    final amount = _extractAmount(sms.body);
    final transactionType = _extractTransactionType(sms.body);
    final merchant = _extractMerchant(sms.body, transactionType);
    final reference = _extractReference(sms.body);
    final bankName = _extractBankName(sms.senderAddress, sms.body);

    final paymentMethod = _extractPaymentMethod(sms.body);
    
    return sms.copyWith(
      amount: amount,
      transactionType: transactionType,
      merchant: merchant,
      reference: reference,
      bankName: bankName,
      paymentMethod: paymentMethod,
    );
  }

  static bool _isBankTransaction(String body) {
    final lowerBody = body.toLowerCase();
    
    // HDFC specific patterns
    if (lowerBody.contains('hdfc')) {
      // Check for HDFC transaction patterns
      final hasHdfcPattern = lowerBody.contains('sent rs') ||
          lowerBody.contains('spent rs') ||
          lowerBody.contains('credit alert') ||
          lowerBody.contains('credited to') ||
          lowerBody.contains('credited to a/c') ||
          lowerBody.contains('from hdfc bank');
      
      return hasHdfcPattern;
    }
    
    // Canara Bank specific patterns
    if (lowerBody.contains('canara bank')) {
      // Canara Bank uses "has been credited/debited"
      final hasCanaraPattern = lowerBody.contains('has been credited') ||
          lowerBody.contains('has been debited') ||
          lowerBody.contains('avail.bal');
      
      return hasCanaraPattern;
    }
    
    // Generic bank transaction keywords for other banks
    final hasTransactionKeyword = lowerBody.contains('credited') ||
        lowerBody.contains('debited') ||
        lowerBody.contains('withdrawn') ||
        lowerBody.contains('deposited') ||
        lowerBody.contains('transferred') ||
        lowerBody.contains('payment') ||
        lowerBody.contains('purchase') ||
        lowerBody.contains('atm') ||
        lowerBody.contains('upi') ||
        lowerBody.contains('neft') ||
        lowerBody.contains('imps') ||
        lowerBody.contains('rtgs');
    
    // Check for amount patterns
    final hasAmount = _amountRegex.hasMatch(body) || 
        _alternativeAmountRegex.hasMatch(body) ||
        RegExp(r'Rs\.\s*([0-9,]+(?:\.[0-9]{1,2})?)', caseSensitive: false).hasMatch(body);
    
    // Check for account references
    final hasAccountRef = lowerBody.contains('a/c') ||
        lowerBody.contains('account') ||
        lowerBody.contains('acct') ||
        lowerBody.contains('card') ||
        RegExp(r'xxxxx?\d{4,5}', caseSensitive: false).hasMatch(body);
    
    return hasTransactionKeyword && hasAmount && hasAccountRef;
  }

  static double? _extractAmount(String body) {
    // Try HDFC specific patterns first
    var match = _hdfcSentAmountRegex.firstMatch(body);
    if (match == null) {
      match = _hdfcSpentAmountRegex.firstMatch(body);
    }
    
    // Try HDFC Bank: Rs. pattern
    if (match == null) {
      match = RegExp(r'Rs\.\s*([0-9,]+(?:\.[0-9]{1,2})?)', caseSensitive: false).firstMatch(body);
    }
    
    // Try Canara Bank INR pattern with commas
    if (match == null) {
      match = RegExp(r'INR\s*([0-9,]+(?:\.[0-9]{1,2})?)', caseSensitive: false).firstMatch(body);
    }
    
    // Try generic patterns
    if (match == null) {
      match = _amountRegex.firstMatch(body);
    }
    if (match == null) {
      // Try alternative regex
      match = _alternativeAmountRegex.firstMatch(body);
    }
    
    if (match != null) {
      final amountStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(amountStr);
    }
    
    return null;
  }

  static TransactionType? _extractTransactionType(String body) {
    final lowerBody = body.toLowerCase();
    
    // HDFC specific patterns
    if (lowerBody.contains('hdfc')) {
      if (lowerBody.contains('credit alert') || 
          lowerBody.contains('credited to') ||
          lowerBody.contains('credited to a/c')) {
        return TransactionType.credit;
      }
      if (lowerBody.startsWith('sent rs') || 
          lowerBody.startsWith('spent rs') ||
          lowerBody.contains('from hdfc bank')) {
        return TransactionType.debit;
      }
    }
    
    // Canara Bank specific patterns
    if (lowerBody.contains('canara bank')) {
      if (lowerBody.contains('has been credited')) {
        return TransactionType.credit;
      }
      if (lowerBody.contains('has been debited')) {
        return TransactionType.debit;
      }
    }
    
    // Generic credit indicators
    if (lowerBody.contains('credited') ||
        lowerBody.contains('deposited') ||
        lowerBody.contains('received') ||
        lowerBody.contains('refund') ||
        lowerBody.contains('cashback') ||
        lowerBody.contains('cr.') ||
        lowerBody.contains('credit')) {
      return TransactionType.credit;
    }
    
    // Generic debit indicators
    if (lowerBody.contains('debited') ||
        lowerBody.contains('withdrawn') ||
        lowerBody.contains('purchase') ||
        lowerBody.contains('payment') ||
        lowerBody.contains('dr.') ||
        lowerBody.contains('debit') ||
        lowerBody.contains('spent')) {
      return TransactionType.debit;
    }
    
    return null;
  }

  static String? _extractMerchant(String body, TransactionType? type) {
    if (type == null) return null;
    
    // HDFC specific patterns
    if (body.toLowerCase().contains('hdfc')) {
      // Pattern: "To [Merchant Name]\nOn"
      final hdfcToPattern = RegExp(r'To\s+([^\n]+)\s*\n\s*On', caseSensitive: false);
      final hdfcToMatch = hdfcToPattern.firstMatch(body);
      if (hdfcToMatch != null) {
        return hdfcToMatch.group(1)?.trim();
      }
      
      // Pattern: "At [Merchant] On" (for card transactions)
      final hdfcAtPattern = RegExp(r'At\s+([A-Za-z0-9\s&.-]+?)\s+On', caseSensitive: false);
      final hdfcAtMatch = hdfcAtPattern.firstMatch(body);
      if (hdfcAtMatch != null) {
        return hdfcAtMatch.group(1)?.trim();
      }
      
      // Pattern: "from VPA [upi-id]" (extract sender for credits)
      if (type == TransactionType.credit) {
        final vpaPattern = RegExp(r'from\s+VPA\s+([^\s]+)', caseSensitive: false);
        final vpaMatch = vpaPattern.firstMatch(body);
        if (vpaMatch != null) {
          return vpaMatch.group(1)?.trim();
        }
      }
      
      // HDFC pattern: "by a/c linked to VPA [upi-id]"
      final linkedVpaPattern = RegExp(r'by\s+a/c\s+linked\s+to\s+VPA\s+([^\s]+)', caseSensitive: false);
      final linkedVpaMatch = linkedVpaPattern.firstMatch(body);
      if (linkedVpaMatch != null) {
        return linkedVpaMatch.group(1)?.trim();
      }
    }
    
    // Canara Bank patterns
    if (body.toLowerCase().contains('canara bank')) {
      // Pattern: "towards [description]"
      final towardsPattern = RegExp(r'towards\s+([^.]+?)(?:\.|Total)', caseSensitive: false);
      final towardsMatch = towardsPattern.firstMatch(body);
      if (towardsMatch != null) {
        final merchant = towardsMatch.group(1)?.trim();
        // Clean up Canara-specific patterns
        if (merchant != null && !merchant.toLowerCase().contains('services charges')) {
          return merchant;
        }
      }
    }
    
    // Generic patterns
    final patterns = [
      // UPI patterns
      RegExp(r'(?:to|from)\s+([A-Za-z0-9\s&.-]+?)(?:\s+on|\s+via|\s+UPI|$)', caseSensitive: false),
      // ATM patterns
      RegExp(r'ATM\s*(?:WDL|withdrawal)?\s*(?:at\s+)?([A-Za-z0-9\s&.-]+?)(?:\s+on|$)', caseSensitive: false),
      // Purchase patterns
      RegExp(r'(?:at|from)\s+([A-Za-z0-9\s&.-]+?)(?:\s+on|\s+for|$)', caseSensitive: false),
      // Transfer patterns
      RegExp(r'(?:transferred to|received from)\s+([A-Za-z0-9\s&.-]+?)(?:\s+on|\s+via|$)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final merchant = match.group(1)?.trim();
        if (merchant != null && merchant.isNotEmpty) {
          // Clean up merchant name
          return merchant
              .replaceAll(RegExp(r'\s+'), ' ')
              .replaceAll(RegExp(r'^(to|from|at)\s+', caseSensitive: false), '')
              .trim();
        }
      }
    }
    
    // Fallback: Look for common payment methods
    if (body.toUpperCase().contains('ATM')) {
      return 'ATM Withdrawal';
    } else if (body.toUpperCase().contains('UPI')) {
      return 'UPI Transfer';
    } else if (body.toUpperCase().contains('NEFT')) {
      return 'NEFT Transfer';
    } else if (body.toUpperCase().contains('IMPS')) {
      return 'IMPS Transfer';
    } else if (body.toUpperCase().contains('RTGS')) {
      return 'RTGS Transfer';
    }
    
    return null;
  }

  static String? _extractReference(String body) {
    // HDFC specific pattern: "Ref 106939189288"
    if (body.toLowerCase().contains('hdfc')) {
      final hdfcRefPattern = RegExp(r'Ref\s+([0-9]+)', caseSensitive: false);
      final hdfcMatch = hdfcRefPattern.firstMatch(body);
      if (hdfcMatch != null) {
        return hdfcMatch.group(1);
      }
      
      // Also check for UPI reference in HDFC messages
      final upiRefPattern = RegExp(r'\(UPI\s+Ref\s+No\s+([0-9]+)\)', caseSensitive: false);
      final upiMatch = upiRefPattern.firstMatch(body);
      if (upiMatch != null) {
        return upiMatch.group(1);
      }
      
      // Simple UPI reference pattern
      final simpleUpiPattern = RegExp(r'\(UPI\s+([0-9]+)\)', caseSensitive: false);
      final simpleUpiMatch = simpleUpiPattern.firstMatch(body);
      if (simpleUpiMatch != null) {
        return simpleUpiMatch.group(1);
      }
    }
    
    // Common reference patterns
    final patterns = [
      RegExp(r'(?:ref|reference|txn|transaction)[\s.:#]*(?:no\s+)?([A-Za-z0-9]+)', caseSensitive: false),
      RegExp(r'(?:info|inf)[\s.:#]*([A-Za-z0-9*]+)', caseSensitive: false),
      RegExp(r'(?:utr|rrn)[\s.:#]*([A-Za-z0-9]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        return match.group(1);
      }
    }
    
    return null;
  }

  static String? _extractBankName(String sender, String body) {
    // First check sender address
    final upperSender = sender.toUpperCase();
    for (final entry in _bankIdentifiers.entries) {
      if (upperSender.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Then check message body
    final upperBody = body.toUpperCase();
    for (final entry in _bankIdentifiers.entries) {
      if (upperBody.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }
  
  static String? _extractPaymentMethod(String body) {
    final lowerBody = body.toLowerCase();
    
    // Check for UPI
    if (lowerBody.contains('upi') || 
        lowerBody.contains('vpa') ||
        lowerBody.contains('@')) {
      return 'UPI';
    }
    
    // Check for Card transactions
    if (lowerBody.contains('card') ||
        lowerBody.contains('debit card') ||
        lowerBody.contains('credit card') ||
        RegExp(r'card\s*x?\d{4}', caseSensitive: false).hasMatch(body)) {
      return 'Card';
    }
    
    // Check for ATM
    if (lowerBody.contains('atm')) {
      return 'ATM';
    }
    
    // Check for Cash deposit
    if (lowerBody.contains('cash-bna') || 
        lowerBody.contains('cash deposit') ||
        (lowerBody.contains('cash') && lowerBody.contains('deposit'))) {
      return 'Cash';
    }
    
    // Check for NEFT/IMPS/RTGS
    if (lowerBody.contains('neft')) {
      return 'NEFT';
    }
    if (lowerBody.contains('imps')) {
      return 'IMPS';
    }
    if (lowerBody.contains('rtgs')) {
      return 'RTGS';
    }
    
    // Default to detecting based on patterns
    if (RegExp(r'sent\s+rs', caseSensitive: false).hasMatch(body)) {
      return 'UPI'; // HDFC "Sent Rs" messages are typically UPI
    }
    
    if (RegExp(r'spent\s+rs', caseSensitive: false).hasMatch(body)) {
      return 'Card'; // HDFC "Spent Rs" messages are typically card transactions
    }
    
    // For service charges
    if (lowerBody.contains('services charges') || 
        lowerBody.contains('service charge')) {
      return 'Bank Charge';
    }
    
    return null;
  }
}