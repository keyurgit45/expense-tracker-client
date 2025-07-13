import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_message_model.dart';
import '../models/chat_session_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final AuthRepository authRepository;
  final Uuid uuid;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authRepository,
    required this.uuid,
  });

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String message,
    required String sessionId,
  }) async {
    try {
      // Get access token if user is authenticated
      String? accessToken;
      final authResult = await authRepository.getCurrentUser();
      authResult.fold(
        (failure) => null,
        (user) => accessToken = user?.accessToken,
      );

      // Create user message
      final userMessage = ChatMessageModel(
        id: uuid.v4(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
        sessionId: sessionId,
      );

      // Save user message locally
      await localDataSource.addMessageToSession(sessionId, userMessage);

      // Send message to remote server
      final response = await remoteDataSource.sendMessage(
        message: message,
        sessionId: sessionId,
        accessToken: accessToken,
      );

      // Create assistant message from response
      final assistantMessage = ChatMessageModel(
        id: uuid.v4(),
        content: response.response,
        isUser: false,
        timestamp: response.timestamp,
        sessionId: sessionId,
      );

      // Save assistant message locally
      await localDataSource.addMessageToSession(sessionId, assistantMessage);

      return Right(assistantMessage);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatSession>> getSession(String sessionId) async {
    try {
      final session = await localDataSource.getSession(sessionId);
      if (session == null) {
        return Left(CacheFailure(message: 'Session not found'));
      }
      return Right(session);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatSession>> createNewSession() async {
    try {
      final session = ChatSessionModel(
        id: uuid.v4(),
        messages: [],
        createdAt: DateTime.now(),
      );
      
      await localDataSource.saveSession(session);
      return Right(session);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChatSession>>> getAllSessions() async {
    try {
      final sessions = await localDataSource.getAllSessions();
      return Right(sessions);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await localDataSource.deleteSession(sessionId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }
}