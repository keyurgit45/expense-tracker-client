import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../entities/chat_session.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String message,
    required String sessionId,
  });
  
  Future<Either<Failure, ChatSession>> getSession(String sessionId);
  
  Future<Either<Failure, ChatSession>> createNewSession();
  
  Future<Either<Failure, List<ChatSession>>> getAllSessions();
  
  Future<Either<Failure, void>> deleteSession(String sessionId);
}