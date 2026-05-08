import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  // Will be populated with user data once authenticated
  final Map<String, dynamic>? userMetadata; 

  AuthState({this.status = AuthStatus.initial, this.userMetadata});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkAuth();
  }

  void _checkAuth() async {
    // Simulate checking Firebase Auth
    await Future.delayed(const Duration(seconds: 2));
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> login(String email, String password) async {
    // Mock login logic
    state = AuthState(status: AuthStatus.authenticated, userMetadata: {'email': email, 'role': 'estudiante'});
  }

  void logout() {
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
