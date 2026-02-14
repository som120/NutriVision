import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ─── Data Source Providers ────────────────────────────────────
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

// ─── Repository Providers ────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

// ─── Auth State Provider ─────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

// ─── Current User Provider ───────────────────────────────────
final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.getUserProfile(user.uid);
      return result.fold((failure) => null, (userEntity) => userEntity);
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

// ─── Auth Notifier ───────────────────────────────────────────
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Auth state
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UserEntity? user;

  const AuthState({this.isLoading = false, this.errorMessage, this.user});

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserEntity? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

/// Auth state notifier handling sign in/sign up/sign out
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.signInWithGoogle();
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.sendPasswordResetEmail(email);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
