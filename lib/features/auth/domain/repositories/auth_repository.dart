import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_credentials.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> signUp(AuthCredentials credentials);
  Future<Either<Failure, AuthUser>> login(AuthCredentials credentials);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthUser>> refreshToken();
  Future<Either<Failure, AuthUser?>> getCurrentUser();
  Stream<AuthUser?> get authStateChanges;
}