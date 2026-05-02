import 'package:flutter/material.dart';
import 'psychiatrist_dashboard/dashboard_screen.dart';
import 'gp_dashboard/dashboard_screen.dart';
import 'pharmacist_dashboard/dashboard_screen.dart';
import 'lab_module/dashboard_screen.dart';
import 'emergency/emergency_hub_screen.dart';
import 'psychiatrist_dashboard/repository.dart';
import 'auth/login_screen.dart';
import 'auth/auth_service.dart';
import 'psychiatrist_dashboard/mock_repository.dart';
import 'psychiatrist_dashboard/firestore_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home/home_screen.dart';
import 'admin/repository/admin_repository.dart'; // [ADMIN]
import 'chat/repository.dart';
import 'chat/mock_repository.dart';
import 'chat/firestore_repository.dart';
import 'chat/chat_list_screen.dart';
import 'admin/ui/admin_dashboard.dart'; // [ADMIN]
import 'appointments/booking_screen.dart';
import 'appointments/my_appointments_screen.dart';
import 'prescriptions/prescription_form_screen.dart';
import 'prescriptions/student_prescriptions_screen.dart';
import 'firebase_options.dart';
import 'notifications/notification_service.dart';
import 'psychiatrist_dashboard/models.dart';
import 'notifications/notifications_screen.dart';
import 'records/repository.dart';
import 'records/record.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<bool> _bootstrapFuture = _bootstrapApp();

  Future<bool> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return true;
    } catch (_) {
      try {
        await Firebase.initializeApp();
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  Future<bool> _bootstrapApp() async {
    final firebaseReady = await _initializeFirebase();

    if (firebaseReady) {
      try {
        repository = FirestoreRepository();
        chatRepository = FirestoreChatRepository();
        recordsRepository = FirestoreRecordsRepository();
      } catch (_) {
        initMockRepository();
        initMockChatRepository();
        initMockRecordsRepository();
      }
      initAdminMockRepository();
    } else {
      initMockRepository();
      initMockChatRepository();
      initAdminMockRepository();
      initMockRecordsRepository();
    }

    await AppNotificationService.instance.initialize(
      enableRemoteMessaging: firebaseReady,
    );

    try {
      AuthService.instance.init();
    } catch (_) {}

    return firebaseReady;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NUST Campus Health',
          onGenerateRoute: (settings) {
            if (settings.name == '/my_appointments') {
              return MaterialPageRoute(
                builder: (_) => const MyAppointmentsScreen(),
                settings: settings,
              );
            }

            if (settings.name == '/medical_records') {
              return MaterialPageRoute(
                builder: (_) => const MedicalRecordsScreen(),
                settings: settings,
              );
            }

            if (settings.name == '/chat_list') {
              if (AuthService.instance.isLoggedIn.value) {
                return MaterialPageRoute(
                  builder: (_) => ChatListScreen(
                    userId: AuthService.instance.currentUserId,
                    userRole: AuthService.instance.userRole.value.name,
                  ),
                  settings: settings,
                );
              } else {
                return MaterialPageRoute(
                  builder: (_) => LoginScreen(redirectTo: '/chat_list'),
                  settings: settings,
                );
              }
            }

            if (settings.name == '/book_appointment') {
              return MaterialPageRoute(
                builder: (_) => const BookingScreen(),
                settings: settings,
              );
            }

            if (settings.name == '/student_prescriptions') {
              return MaterialPageRoute(
                builder: (_) => const StudentPrescriptionsScreen(),
                settings: settings,
              );
            }

            if (settings.name == '/prescription_form') {
              final patient = settings.arguments as Patient;
              return MaterialPageRoute(
                builder: (_) => PrescriptionFormScreen(patient: patient),
                settings: settings,
              );
            }

            if (settings.name == '/emergency_hub') {
              return MaterialPageRoute(
                builder: (_) => const EmergencyHubScreen(),
                settings: settings,
              );
            }

            if (settings.name == '/notifications') {
              if (AuthService.instance.isLoggedIn.value) {
                return MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                  settings: settings,
                );
              } else {
                return MaterialPageRoute(
                  builder: (_) => LoginScreen(redirectTo: '/notifications'),
                  settings: settings,
                );
              }
            }

            if (settings.name == '/lab_dashboard') {
              if (AuthService.instance.isLoggedIn.value) {
                return MaterialPageRoute(
                  builder: (_) => const LabDashboardScreen(),
                  settings: settings,
                );
              } else {
                return MaterialPageRoute(
                  builder: (_) => LoginScreen(redirectTo: '/lab_dashboard'),
                  settings: settings,
                );
              }
            }

            if (settings.name == '/pharmacist_dashboard') {
              if (AuthService.instance.isLoggedIn.value) {
                return MaterialPageRoute(
                  builder: (_) => const PharmacistDashboardScreen(),
                  settings: settings,
                );
              } else {
                return MaterialPageRoute(
                  builder: (_) =>
                      LoginScreen(redirectTo: '/pharmacist_dashboard'),
                  settings: settings,
                );
              }
            }

            if (settings.name == '/gp_dashboard') {
              if (AuthService.instance.isLoggedIn.value) {
                return MaterialPageRoute(
                  builder: (_) => const GPDashboardScreen(),
                  settings: settings,
                );
              } else {
                return MaterialPageRoute(
                  builder: (_) => LoginScreen(redirectTo: '/gp_dashboard'),
                  settings: settings,
                );
              }
            }

            // central route guard: require auth for protected routes
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

            if (settings.name == '/admin') {
              if (AuthService.instance.isLoggedIn.value &&
                  AuthService.instance.userRole.value == UserRole.admin) {
                return MaterialPageRoute(
                  builder: (_) => const AdminDashboard(),
                  settings: settings,
                );
              } else {
                return MaterialPageRoute(
                  builder: (_) => LoginScreen(redirectTo: '/admin'),
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

            return MaterialPageRoute(
              builder: (_) => ValueListenableBuilder<bool>(
                valueListenable: AuthService.instance.isLoggedIn,
                builder: (context, loggedIn, _) {
                  if (!loggedIn) {
                    return const LoginScreen();
                  }

                  // If logged in, redirect based on role
                  final role = AuthService.instance.userRole.value;
                  switch (role) {
                    case UserRole.admin:
                      return const AdminDashboard();
                    case UserRole.psychiatrist:
                      return const PsychiatristDashboardScreen();
                    case UserRole.gp:
                      return const GPDashboardScreen();
                    case UserRole.pharmacist:
                      return const PharmacistDashboardScreen();
                    case UserRole.lab_tech:
                      return const LabDashboardScreen();
                    case UserRole.student:
                    default:
                      return const HomeScreen();
                  }
                },
              ),
              settings: settings,
            );
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
