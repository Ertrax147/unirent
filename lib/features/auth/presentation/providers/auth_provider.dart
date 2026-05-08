import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges async* {
    await Future.delayed(const Duration(seconds: 2));
    yield null;
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return UserEntity(
      id: 'mock_uid_123',
      email: 'mock@ufromail.cl',
      name: 'Usuario Prueba',
      photoUrl: '',
      role: 'unassigned',
      isPhoneVerified: false,
    );
  }

  @override
  Future<UserEntity> updateUserRole(String uid, String role) async {
    await Future.delayed(const Duration(seconds: 1));
    return UserEntity(
      id: uid,
      email: 'mock@ufromail.cl',
      name: 'Usuario Prueba',
      photoUrl: '',
      role: role,
      isPhoneVerified: false,
    );
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Use mock for UI testing since Firebase is not fully configured
  return MockAuthRepository() as AuthRepository;
});

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  AuthState({this.status = AuthStatus.initial, this.user, this.errorMessage});

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _initAuthListener();
  }

  void _initAuthListener() {
    _repository.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      } else {
        // Need to refetch user from Firestore when app starts
        try {
          final userEntity = await _repository.signInWithGoogle(); // or another method to just get firestore data
          // To avoid infinite loop or calling Google SignIn popup again, we can just fetch the user directly
          // For simplicity in this provider, we'll wait for the explicit login call to populate state
          // Or we can expose a _repository.getUserEntity(firebaseUser.uid)
        } catch (e) {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final user = await _repository.signInWithGoogle();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> assignRole(String role) async {
    if (state.user == null) return;
    try {
      state = state.copyWith(status: AuthStatus.authenticating);
      final updatedUser = await _repository.updateUserRole(state.user!.id, role);
      state = state.copyWith(status: AuthStatus.authenticated, user: updatedUser);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
