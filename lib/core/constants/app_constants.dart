class AppConstants {
  static const String appName = 'Expenses';
  
  // API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // Cache
  static const String userCacheKey = 'USER_CACHE_KEY';
  static const String tokenCacheKey = 'TOKEN_CACHE_KEY';
  static const String onboardingKey = 'ONBOARDING_COMPLETE';
  
  // Pagination
  static const int pageSize = 20;
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';
  
  // Currency
  static const String defaultCurrency = 'INR';
  static const String currencySymbol = '₹';
  
  // Transaction
  static const int transactionDescriptionMaxLength = 500;
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 999999.99;
  
  // Categories
  static const int maxCategoryNameLength = 50;
  
  // Tags
  static const int maxTagNameLength = 30;
  static const int maxTagsPerTransaction = 10;
}