import 'package:flutter/foundation.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  String? currentUser;

  // Simple mock login: username 'psy' and password 'password'
  Future<bool> login(String username, String password) async {
    // In a real app this would call an API
    final ok = (username == 'psy' && password == 'password');
    isLoggedIn.value = ok;
    if (ok) currentUser = username;
    return Future.value(ok);
  }

  Future<void> logout() async {
    isLoggedIn.value = false;
    currentUser = null;
    return Future.value();
  }
}
