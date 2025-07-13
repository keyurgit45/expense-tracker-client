import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendMessage implements UseCase<ChatMessage, SendMessageParams> {
  final ChatRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, ChatMessage>> call(SendMessageParams params) {
    return repository.sendMessage(
      message: params.message,
      sessionId: params.sessionId,
    );
  }
}

class SendMessageParams extends Equatable {
  final String message;
  final String sessionId;

  const SendMessageParams({
    required this.message,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [message, sessionId];
}