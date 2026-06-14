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
    bool clearVerificationId = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      verificationId: clearVerificationId ? null : (verificationId ?? this.verificationId),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _initAuthListener();
  }

  void clearVerificationId() {
    state = state.copyWith(clearVerificationId: true);
  }

  void _initAuthListener() {
    _repository.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      } else {
        // Fetch user from Spring Boot quietly on app start.
        // Si ya estamos autenticando manualmente (ej: signInWithGoogle), dejamos que ese método se encargue
        if (state.status == AuthStatus.authenticating) {
          return;
        }
        try {
          final userEntity = await _repository.getUserEntityFromBackend(firebaseUser);
          state = state.copyWith(status: AuthStatus.authenticated, user: userEntity);
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

  Future<void> registrarUsuario(String role, String telefono) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      // Usar _repository explícitamente en lugar de await
      final updatedUser = await _repository.registrarUsuario(role, telefono);
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
      // In this flow, verifying the SMS code links it to the Firebase account, but doesn't change the UserEntity yet.
      // We return a UserEntity from the repository just to keep it consistent, but we don't strictly need it.
      await _repository.verifySmsCode(state.verificationId!, smsCode);
      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null, clearVerificationId: true);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
