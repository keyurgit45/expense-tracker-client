import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/chat_response_model.dart';

abstract class ChatRemoteDataSource {
  Future<ChatResponseModel> sendMessage({
    required String message,
    required String sessionId,
    required String? accessToken,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  ChatRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<ChatResponseModel> sendMessage({
    required String message,
    required String sessionId,
    required String? accessToken,
  }) async {
    try {
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };
      
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      
      final response = await dio.post(
        '$baseUrl/api/v1/chat',
        data: {
          'message': message,
          'session_id': sessionId,
        },
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        return ChatResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Failed to send message: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ServerException(
          message: 'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw ServerException(
          message: 'Unable to connect to chat server. Please try again later.',
        );
      } else if (e.response != null) {
        throw ServerException(
          message: 'Server error: ${e.response?.statusCode} - ${e.response?.data?['error'] ?? 'Unknown error'}',
        );
      } else {
        throw ServerException(
          message: 'Network error: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error: $e',
      );
    }
  }
}