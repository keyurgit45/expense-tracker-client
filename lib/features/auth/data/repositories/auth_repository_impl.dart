import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  final _authStateController = StreamController<AuthUser?>.broadcast();

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  }) {
    _initializeAuthState();
  }

  void _initializeAuthState() async {
    final user = await localDataSource.getCachedAuthUser();
    if (user != null && !user.isTokenExpired) {
      _authStateController.add(user);
    } else {
      _authStateController.add(null);
    }
  }

  @override
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  @override
  Future<Either<Failure, AuthUser>> signUp(AuthCredentials credentials) async {
    try {
      final user = await remoteDataSource.signUp(
        credentials.email,
        credentials.password,
      );
      await localDataSource.cacheAuthUser(user);
      _authStateController.add(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> login(AuthCredentials credentials) async {
    try {
      final user = await remoteDataSource.login(
        credentials.email,
        credentials.password,
      );
      await localDataSource.cacheAuthUser(user);
      _authStateController.add(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final user = await localDataSource.getCachedAuthUser();
      if (user != null) {
        await remoteDataSource.logout(user.accessToken);
      }
      await localDataSource.clearAuthUser();
      _authStateController.add(null);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException {
      return const Left(CacheFailure(message: 'Authentication failed'));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> refreshToken() async {
    try {
      final cachedUser = await localDataSource.getCachedAuthUser();
      if (cachedUser == null) {
        return const Left(CacheFailure(message: 'Authentication failed'));
      }
      
      final user = await remoteDataSource.refreshToken(cachedUser.refreshToken);
      await localDataSource.cacheAuthUser(user);
      _authStateController.add(user);
      return Right(user);
    } on ServerException catch (e) {
      await localDataSource.clearAuthUser();
      _authStateController.add(null);
      return Left(ServerFailure(message: e.message));
    } on CacheException {
      return const Left(CacheFailure(message: 'Authentication failed'));
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedAuthUser();
      if (user != null && !user.isTokenExpired) {
        return Right(user);
      } else if (user != null && user.isTokenExpired) {
        return await refreshToken();
      }
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure(message: 'Authentication failed'));
    }
  }

  void dispose() {
    _authStateController.close();
  }
}