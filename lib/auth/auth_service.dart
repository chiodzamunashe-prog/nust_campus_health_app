import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  String? currentUser;

  bool _firebaseAvailable = false;
  fb.FirebaseAuth? _fbAuth;

  // Initialize auth service. Safe to call multiple times.
  void init() {
    try {
      _fbAuth = fb.FirebaseAuth.instance;
      _firebaseAvailable = true;
      _fbAuth!.authStateChanges().listen((fb.User? user) {
        isLoggedIn.value = user != null;
        currentUser = user?.email;
      });
    } catch (_) {
      // Firebase not available in this environment (tests / no init)
      _firebaseAvailable = false;
      isLoggedIn.value = false;
      currentUser = null;
    }
  }

  // Login using email/password when Firebase is available, otherwise use mock credentials.
  Future<bool> login(String identifier, String password) async {
    if (!_firebaseAvailable) {
      final ok = (identifier == 'psy' && password == 'password');
      isLoggedIn.value = ok;
      if (ok) currentUser = identifier;
      return Future.value(ok);
    }

    try {
      final result = await _fbAuth!.signInWithEmailAndPassword(email: identifier, password: password);
      final user = result.user;
      isLoggedIn.value = user != null;
      currentUser = user?.email;
      return user != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    if (!_firebaseAvailable) {
      isLoggedIn.value = false;
      currentUser = null;
      return Future.value();
    }
    await _fbAuth!.signOut();
    isLoggedIn.value = false;
    currentUser = null;
  }
}
