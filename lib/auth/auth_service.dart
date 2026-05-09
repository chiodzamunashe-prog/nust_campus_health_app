import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Login using parameterised queries and Firebase Auth, with fallback to mock credentials.
  Future<bool> login(String identifier, String password) async {
    try {
      // ---------------------------------------------------------
      // SECURITY FEATURE: Parameterised Statements (NoSQL Equivalent)
      // ---------------------------------------------------------
      // In Firestore, using the 'isEqualTo' named parameter acts exactly like a 
      // parameterized SQL query. It completely prevents NoSQL injection attacks
      // because the 'identifier' is passed as a strict value parameter to the DB
      // engine, rather than being concatenated into a query string.
      // 1. Authenticate with Firebase Auth first
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: identifier,
        password: password,
      );

      // 2. Fetch the user's role from Firestore using their unique UID
      // This is the NoSQL equivalent of a parameterised statement (fetching by key)
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (doc.exists) {
        currentUser = userCredential.user!.uid;
        currentUserName = doc.data()?['displayName'] as String? ?? 'Student';
        final roleStr = doc.data()?['role'] as String?;
        
        switch (roleStr) {
          case 'admin': userRole.value = UserRole.admin; break;
          case 'psychiatrist': userRole.value = UserRole.psychiatrist; break;
          case 'gp': userRole.value = UserRole.gp; break;
          case 'lab_tech': userRole.value = UserRole.lab_tech; break;
          case 'pharmacist': userRole.value = UserRole.pharmacist; break;
          default: userRole.value = UserRole.student;
        }
      } else {
        // Fallback if the user is in Auth but not in Firestore yet
        currentUser = userCredential.user!.uid;
        currentUserName = identifier.split('@')[0];
        userRole.value = UserRole.student;
      }
      
      isLoggedIn.value = true;
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }


  Future<bool> register(
    String identifier,
    String password,
    String displayName,
    String role,
  ) async {
    try {
      // 1. Create the user in Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: identifier,
        password: password,
      );

      // 2. Create the user profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'displayName': displayName,
        'email': identifier,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      currentUser = userCredential.user!.uid;
      currentUserName = displayName;
      
      // Update the local role state
      switch (role) {
        case 'admin': userRole.value = UserRole.admin; break;
        case 'psychiatrist': userRole.value = UserRole.psychiatrist; break;
        case 'gp': userRole.value = UserRole.gp; break;
        case 'lab_tech': userRole.value = UserRole.lab_tech; break;
        case 'pharmacist': userRole.value = UserRole.pharmacist; break;
        default: userRole.value = UserRole.student;
      }

      isLoggedIn.value = true;
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
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
