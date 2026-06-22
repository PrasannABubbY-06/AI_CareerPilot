import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

final authServiceProvider =
    Provider<AuthService>((ref) {

  return AuthService();
});

final authStateProvider =
    StateNotifierProvider<AuthNotifier, User?>((ref) {

  return AuthNotifier(
    ref.read(authServiceProvider),
  );
});

class AuthNotifier
    extends StateNotifier<User?> {

  final AuthService _authService;

  AuthNotifier(this._authService)
      : super(null) {

    state = _authService.currentUser;
  }

  // =====================================================
  // LOGIN
  // =====================================================

  Future<void> login(

    String email,
    String password,

  ) async {

    final credential =
        await _authService.login(

      email: email,
      password: password,
    );

    state = credential.user;
  }

  // =====================================================
  // REGISTER
  // =====================================================

  Future<void> register(

    String email,
    String password,

  ) async {

    final credential =
        await _authService.signUp(

      email: email,
      password: password,
      role: "user",

    );

    state = credential.user;
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {

    await _authService.logout();

    state = null;
  }
}