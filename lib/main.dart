import 'package:flutter/material.dart';
import 'psychiatrist_dashboard/dashboard_screen.dart';
import 'psychiatrist_dashboard/repository.dart';
import 'auth/login_screen.dart';
import 'auth/auth_service.dart';
import 'psychiatrist_dashboard/mock_repository.dart';
import 'psychiatrist_dashboard/firestore_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home/home_screen.dart';
import 'admin/repository/admin_repository.dart'; // [ADMIN]
import 'admin/ui/admin_dashboard.dart'; // [ADMIN]
import 'appointments/booking_screen.dart';
import 'appointments/my_appointments_screen.dart';
import 'prescriptions/prescription_form_screen.dart';
import 'prescriptions/student_prescriptions_screen.dart';
import 'models/prescription_model.dart';
import 'psychiatrist_dashboard/models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          try {
            repository = FirestoreRepository();
          } catch (_) {
            initMockRepository();
          }
          initAdminMockRepository();
        } else {
          initMockRepository();
          initAdminMockRepository();
        }

        try {
          AuthService.instance.init();
        } catch (_) {}

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NUST Campus Health',
          onGenerateRoute: (settings) {
            if (settings.name == '/my_appointments') {
              return MaterialPageRoute(builder: (_) => const MyAppointmentsScreen(), settings: settings);
            }

            if (settings.name == '/book_appointment') {
              return MaterialPageRoute(builder: (_) => const BookingScreen(), settings: settings);
            }

            if (settings.name == '/student_prescriptions') {
              return MaterialPageRoute(builder: (_) => const StudentPrescriptionsScreen(), settings: settings);
            }

            if (settings.name == '/prescription_form') {
              final patient = settings.arguments as Patient;
              return MaterialPageRoute(builder: (_) => PrescriptionFormScreen(patient: patient), settings: settings);
            }

            // central route guard: require auth for protected routes
            if (settings.name == '/psy_dashboard') {
              if (AuthService.instance.isLoggedIn.value) {
                return MaterialPageRoute(builder: (_) => const PsychiatristDashboardScreen(), settings: settings);
              } else {
                return MaterialPageRoute(builder: (_) => LoginScreen(redirectTo: '/psy_dashboard'), settings: settings);
              }
            }

            if (settings.name == '/admin') {
              if (AuthService.instance.isLoggedIn.value && AuthService.instance.userRole.value == UserRole.admin) {
                return MaterialPageRoute(builder: (_) => const AdminDashboard(), settings: settings);
              } else {
                return MaterialPageRoute(builder: (_) => LoginScreen(redirectTo: '/admin'), settings: settings);
              }
            }

            if (settings.name == '/login') {
              final args = settings.arguments;
              String? redirect;
              if (args is String) redirect = args;
              return MaterialPageRoute(builder: (_) => LoginScreen(redirectTo: redirect), settings: settings);
            }

            return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);
          },
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF003366),
              primary: const Color(0xFF003366),
              secondary: const Color(0xFFFFB81C),
              surface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF003366),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
                foregroundColor: Colors.white,
              ),
            ),
            chipTheme: const ChipThemeData(
              selectedColor: Color(0xFFFFB81C),
              secondarySelectedColor: Color(0xFF003366),
              labelStyle: TextStyle(color: Colors.black87),
              secondaryLabelStyle: TextStyle(color: Colors.white),
            ),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
