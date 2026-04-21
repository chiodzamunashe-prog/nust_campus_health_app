import 'package:flutter/material.dart';
import 'psychiatrist_dashboard/dashboard_screen.dart';
import 'psychiatrist_dashboard/repository.dart';
import 'auth/login_screen.dart';
import 'auth/auth_service.dart';
import 'psychiatrist_dashboard/mock_repository.dart';
import 'psychiatrist_dashboard/firestore_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Initialize repository to Firestore if Firebase initialized, otherwise use mock
        if (snapshot.connectionState == ConnectionState.done) {
          try {
            repository = FirestoreRepository();
          } catch (_) {
            initMockRepository();
          }
        } else {
          initMockRepository();
        }

        // Initialize auth service (Firebase-aware). Safe to call multiple times.
        try {
          AuthService.instance.init();
        } catch (_) {
          // ignore
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          onGenerateRoute: (settings) {
            // Centralized route guard: require auth for /psy_dashboard
            if (settings.name == '/psy_dashboard') {
              if (AuthService.instance.isLoggedIn.value) {
                return MaterialPageRoute(
                  builder: (_) => const PsychiatristDashboardScreen(),
                  settings: settings,
                );
              } else {
                return MaterialPageRoute(
                  builder: (_) => LoginScreen(redirectTo: '/psy_dashboard'),
                  settings: settings,
                );
              }
            }

            if (settings.name == '/login') {
              final args = settings.arguments;
              String? redirect;
              if (args is String) redirect = args;
              return MaterialPageRoute(
                builder: (_) => LoginScreen(redirectTo: redirect),
                settings: settings,
              );
            }

            // fallback to home
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
              settings: settings,
            );
          },
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF003366),
              primary: const Color(0xFF003366),
              secondary: const Color(0xFFFFB81C),
            ),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
