import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Delay for smooth transition and UI attachment
    final user = _authRepository.currentUser;
    if (user != null) {
      try {
        final profile = await _authRepository.getUserProfile(user.id);
        emit(AuthAuthenticated(profile));
      } catch (_) {
        emit(const AuthUnauthenticated());
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final currentState = state;
    emit(const AuthLoading());
    try {
      final user = await _authRepository.updateProfile(
        userId: userId,
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (currentState is AuthAuthenticated) {
        emit(currentState);
      }
      emit(AuthError(e.toString()));
    }
  }
}
