import 'package:flutter/foundation.dart';
import '../notifications/repository.dart';
import '../notifications/mock_repository.dart';

enum UserRole { none, student, psychiatrist, gp, pharmacist, lab_tech, admin }

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  final ValueNotifier<UserRole> userRole = ValueNotifier<UserRole>(
    UserRole.none,
  );
  String? currentUser;
  String? currentUserName;
  NotificationsRepository? _notificationsRepository;

  String get currentUserId => currentUser ?? 'guest';
  String get currentUserDisplayName =>
      currentUserName ?? currentUser ?? 'Student';

  // Initialize auth service. Safe to call multiple times.
  void init() {
    // No initialization needed, always start logged out
    isLoggedIn.value = false;
    currentUser = null;
    currentUserName = null;
    userRole.value = UserRole.none;
  }

  // Login using email/password when Firebase is available, otherwise use mock credentials.
  Future<bool> login(String identifier, String password) async {
    // Always return false to force registration
    return Future.value(false);
  }

  Future<bool> register(
    String identifier,
    String password,
    String displayName,
  ) async {
    // Always succeed registration
    currentUser = identifier;
    currentUserName = displayName;
    userRole.value = UserRole.student;
    isLoggedIn.value = true;
    return Future.value(true);
  }

  Future<void> logout() async {
    isLoggedIn.value = false;
    userRole.value = UserRole.none;
    currentUser = null;
    currentUserName = null;
  }

  /// Get the notifications repository (Firebase or Mock depending on availability)
  NotificationsRepository getNotificationsRepository() {
    if (_notificationsRepository != null) {
      return _notificationsRepository!;
    }

    _notificationsRepository = MockNotificationsRepository();

    return _notificationsRepository!;
  }
}
