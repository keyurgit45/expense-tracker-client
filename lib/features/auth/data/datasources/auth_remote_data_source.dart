import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserModel> signUp(String email, String password);
  Future<AuthUserModel> login(String email, String password);
  Future<void> logout(String token);
  Future<AuthUserModel> refreshToken(String refreshToken);
  Future<Map<String, dynamic>> getCurrentUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<AuthUserModel> signUp(String email, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/v1/auth/signup',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final userInfoResponse =
            await getCurrentUser(response.data['access_token']);
        return AuthUserModel.fromJson(response.data, userInfoResponse);
      } else {
        throw ServerException(
          message: response.data['detail'] ?? 'Signup failed',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException(
          message: e.response?.data['detail'] ?? 'Email already exists',
        );
      }
      throw ServerException(
        message: e.response?.data['detail'] ?? 'Network error',
      );
    }
  }

  @override
  Future<AuthUserModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final userInfoResponse =
            await getCurrentUser(response.data['access_token']);
        return AuthUserModel.fromJson(response.data, userInfoResponse);
      } else {
        throw ServerException(
          message: response.data['detail'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException(
          message: 'Invalid email or password',
        );
      }
      throw ServerException(
        message: e.response?.data['detail'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      await dio.post(
        '$baseUrl/api/v1/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['detail'] ?? 'Logout failed',
      );
    }
  }

  @override
  Future<AuthUserModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/v1/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final userInfoResponse =
            await getCurrentUser(response.data['access_token']);
        return AuthUserModel.fromJson(response.data, userInfoResponse);
      } else {
        throw ServerException(
          message: response.data['detail'] ?? 'Token refresh failed',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException(
          message: 'Invalid refresh token',
        );
      }
      throw ServerException(
        message: e.response?.data['detail'] ?? 'Network error',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerException(
          message: response.data['detail'] ?? 'Failed to get user info',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['detail'] ?? 'Network error',
      );
    }
  }
}
