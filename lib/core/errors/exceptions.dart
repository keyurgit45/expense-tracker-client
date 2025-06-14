class ServerException implements Exception {
  final String message;
  final String? code;

  ServerException({
    required this.message,
    this.code,
  });
}

class CacheException implements Exception {
  final String message;
  final String? code;

  CacheException({
    required this.message,
    this.code,
  });
}

class NetworkException implements Exception {
  final String message;
  final String? code;

  NetworkException({
    required this.message,
    this.code,
  });
}

class ValidationException implements Exception {
  final String message;
  final String? code;

  ValidationException({
    required this.message,
    this.code,
  });
}