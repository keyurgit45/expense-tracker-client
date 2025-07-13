import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/auth_user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthUser(AuthUserModel user);
  Future<AuthUserModel?> getCachedAuthUser();
  Future<void> clearAuthUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String authUserKey = 'AUTH_USER';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheAuthUser(AuthUserModel user) async {
    final success = await sharedPreferences.setString(
      authUserKey,
      json.encode(user.toJson()),
    );
    if (!success) {
      throw CacheException(message: 'Failed to cache auth user');
    }
  }

  @override
  Future<AuthUserModel?> getCachedAuthUser() async {
    final jsonString = sharedPreferences.getString(authUserKey);
    if (jsonString != null) {
      try {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return AuthUserModel.fromStorageJson(jsonMap);
      } catch (e) {
        throw CacheException(message: 'Failed to parse cached auth user');
      }
    }
    return null;
  }

  @override
  Future<void> clearAuthUser() async {
    final success = await sharedPreferences.remove(authUserKey);
    if (!success) {
      throw CacheException(message: 'Failed to clear auth user');
    }
  }
}