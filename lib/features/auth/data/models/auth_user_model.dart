import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.accessToken,
    required super.refreshToken,
    required super.expiresAt,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json, Map<String, dynamic> userInfo) {
    final expiresIn = json['expires_in'] as int;
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    
    return AuthUserModel(
      id: userInfo['id'] ?? userInfo['sub'] ?? '',
      email: userInfo['email'] ?? '',
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  factory AuthUserModel.fromStorageJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'],
      email: json['email'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}