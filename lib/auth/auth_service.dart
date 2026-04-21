import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

enum UserRole {
  none,
  student,
  psychiatrist,
  gp,
  admin,
}

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  final ValueNotifier<UserRole> userRole = ValueNotifier<UserRole>(UserRole.none);
  String? currentUser;

  bool _firebaseAvailable = false;
  fb.FirebaseAuth? _fbAuth;

  // Initialize auth service. Safe to call multiple times.
  void init() {
    try {
      _fbAuth = fb.FirebaseAuth.instance;
      _firebaseAvailable = true;
      _fbAuth!.authStateChanges().listen((fb.User? user) {
        if (user != null) {
          isLoggedIn.value = true;
          currentUser = user.email;
          // For Firebase, we'd normally fetch role from Firestore.
          // For now, if email contains 'admin', set as admin, else student.
          if (user.email?.contains('admin') ?? false) {
            userRole.value = UserRole.admin;
          } else if (user.email == 'psy') {
            userRole.value = UserRole.psychiatrist;
          } else {
            userRole.value = UserRole.student;
          }
        } else {
          isLoggedIn.value = false;
          currentUser = null;
          userRole.value = UserRole.none;
        }
      });
    } catch (_) {
      // Firebase not available in this environment (tests / no init)
      _firebaseAvailable = false;
      isLoggedIn.value = false;
      currentUser = null;
      userRole.value = UserRole.none;
    }
  }

  // Login using email/password when Firebase is available, otherwise use mock credentials.
  Future<bool> login(String identifier, String password) async {
    if (!_firebaseAvailable) {
      bool ok = false;
      UserRole role = UserRole.none;

      if (identifier == 'admin' && password == 'password') {
        ok = true;
        role = UserRole.admin;
      } else if (identifier == 'psy' && password == 'password') {
        ok = true;
        role = UserRole.psychiatrist;
      }

      isLoggedIn.value = ok;
      userRole.value = role;
      if (ok) currentUser = identifier;
      return Future.value(ok);
    }

    try {
      final result = await _fbAuth!.signInWithEmailAndPassword(email: identifier, password: password);
      final user = result.user;
      isLoggedIn.value = user != null;
      currentUser = user?.email;
      // Role will be set via the listener in init()
      return user != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    if (!_firebaseAvailable) {
      isLoggedIn.value = false;
      userRole.value = UserRole.none;
      currentUser = null;
      return Future.value();
    }
    await _fbAuth!.signOut();
    isLoggedIn.value = false;
    userRole.value = UserRole.none;
    currentUser = null;
  }
}
