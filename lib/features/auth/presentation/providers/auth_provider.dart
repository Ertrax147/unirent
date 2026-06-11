import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final String? verificationId;

  AuthState({
    this.status = AuthStatus.initial, 
    this.user, 
    this.errorMessage,
    this.verificationId,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    String? verificationId,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      verificationId: verificationId ?? this.verificationId,
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

  Future<void> signInWithGoogle({bool isRegister = false}) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final user = await _repository.signInWithGoogle(isRegister: isRegister);
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

  Future<void> sendSmsCode(String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      await _repository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (String verificationId) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            verificationId: verificationId,
          );
        },
        onVerificationFailed: (FirebaseAuthException e) {
          state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
        },
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> verifySmsCode(String smsCode) async {
    if (state.verificationId == null) return;
    
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final updatedUser = await _repository.verifySmsCode(state.verificationId!, smsCode);
      state = state.copyWith(status: AuthStatus.authenticated, user: updatedUser);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null, verificationId: null);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
