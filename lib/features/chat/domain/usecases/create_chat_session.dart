import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';

class CreateChatSession implements UseCase<ChatSession, NoParams> {
  final ChatRepository repository;

  CreateChatSession(this.repository);

  @override
  Future<Either<Failure, ChatSession>> call(NoParams params) {
    return repository.createNewSession();
  }
}