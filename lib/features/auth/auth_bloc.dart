import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthSessionChecked>(_checkSession);
    on<AuthLoginSubmitted>(_login);
    on<AuthLogoutRequested>(_logout);
    on<AuthSessionExpired>(_expired);
    _unauthorizedSubscription = _authRepository.apiClient.unauthorized
        .listen((_) => add(const AuthSessionExpired()));
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<void> _unauthorizedSubscription;

  Future<void> _checkSession(
      AuthSessionChecked event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.restoreSession();
      if (user == null) {
        emit(const AuthUnauthenticated());
        return;
      }
      emit(AuthAuthenticated(user));
    } on AppException catch (error) {
      emit(AuthError(error.message));
    } catch (error) {
      emit(AuthError(readableError(error)));
    }
  }

  Future<void> _login(AuthLoginSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      if (event.identifier.trim().isEmpty || event.password.isEmpty) {
        throw const AppException(
          'Enter your email or phone number and password.',
          type: AppErrorType.validation,
        );
      }

      final user = await _authRepository.login(
        identifier: event.identifier.trim(),
        password: event.password,
      );

      emit(AuthAuthenticated(user));
    } on AppException catch (error) {
      emit(AuthError(error.message));
    } catch (error) {
      emit(AuthError(readableError(error)));
    }
  }

  Future<void> _logout(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.logout();
    } catch (_) {
      await _authRepository.clearSession();
    }
    emit(const AuthUnauthenticated());
  }

  Future<void> _expired(
      AuthSessionExpired event, Emitter<AuthState> emit) async {
    await _authRepository.clearSession();
    emit(const AuthUnauthenticated());
  }

  @override
  Future<void> close() async {
    await _unauthorizedSubscription.cancel();
    return super.close();
  }
}
