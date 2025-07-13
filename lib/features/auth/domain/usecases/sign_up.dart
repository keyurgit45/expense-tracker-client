import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_credentials.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignUp implements UseCase<AuthUser, AuthCredentials> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(AuthCredentials params) async {
    return await repository.signUp(params);
  }
}