import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final Login login;
  final SignUp signUp;
  final Logout logout;
  final AuthRepository authRepository;
  
  StreamSubscription? _authStateSubscription;

  AuthCubit({
    required this.login,
    required this.signUp,
    required this.logout,
    required this.authRepository,
  }) : super(AuthInitial()) {
    _checkAuthStatus();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authStateSubscription = authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> loginUser(String email, String password) async {
    emit(AuthLoading());
    
    final credentials = AuthCredentials(email: email, password: password);
    final result = await login(credentials);
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> signUpUser(String email, String password) async {
    emit(AuthLoading());
    
    final credentials = AuthCredentials(email: email, password: password);
    final result = await signUp(credentials);
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> logoutUser() async {
    emit(AuthLoading());
    
    final result = await logout(NoParams());
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}