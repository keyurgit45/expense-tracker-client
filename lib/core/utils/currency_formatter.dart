import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class CurrencyFormatter {
  static final _currencyFormat = NumberFormat.currency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
    locale: 'en_IN', // Indian locale for proper number formatting
  );

  static final _compactCurrencyFormat = NumberFormat.compactCurrency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
    locale: 'en_IN',
  );

  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatCompact(double amount) {
    return _compactCurrencyFormat.format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    return NumberFormat('#,##,##0.00', 'en_IN').format(amount);
  }

  static double? parse(String value) {
    try {
      // Remove currency symbol and any spaces
      final cleanValue = value
          .replaceAll(AppConstants.currencySymbol, '')
          .replaceAll(',', '')
          .trim();
      return double.parse(cleanValue);
    } catch (e) {
      return null;
    }
  }
}