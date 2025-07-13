import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String email;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthUser({
    required this.id,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isTokenExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [id, email, accessToken, refreshToken, expiresAt];
}