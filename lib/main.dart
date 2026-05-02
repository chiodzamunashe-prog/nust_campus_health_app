import 'package:flutter/material.dart';
import 'psychiatrist_dashboard/dashboard_screen.dart';
import 'gp_dashboard/dashboard_screen.dart';
import 'pharmacist_dashboard/dashboard_screen.dart';
import 'lab_module/dashboard_screen.dart';
import 'emergency/emergency_hub_screen.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'auth/auth_service.dart';
import 'psychiatrist_dashboard/mock_repository.dart';
import 'home/home_screen.dart';
import 'admin/repository/admin_repository.dart'; // [ADMIN]
import 'chat/mock_repository.dart';
import 'chat/chat_list_screen.dart';
import 'admin/ui/admin_dashboard.dart'; // [ADMIN]
import 'appointments/booking_screen.dart';
import 'appointments/my_appointments_screen.dart';
import 'prescriptions/prescription_form_screen.dart';
import 'prescriptions/student_prescriptions_screen.dart';
import 'notifications/notification_service.dart';
import 'psychiatrist_dashboard/models.dart';
import 'notifications/notifications_screen.dart';

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

  Future<bool> _bootstrapApp() async {
    initMockRepository();
    initMockChatRepository();
    initAdminMockRepository();

    await AppNotificationService.instance.initialize(
      enableRemoteMessaging: false,
    );

    AuthService.instance.init();

    return true;
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

        return ValueListenableBuilder<bool>(
          valueListenable: AuthService.instance.isLoggedIn,
          builder: (context, loggedIn, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'NUST Campus Health',
              initialRoute: loggedIn ? '/' : '/login',
              onGenerateRoute: (settings) {
                if (settings.name == '/my_appointments') {
                  return MaterialPageRoute(
                    builder: (_) => const MyAppointmentsScreen(),
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

                if (settings.name == '/register') {
                  return MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                    settings: settings,
                  );
                }

                if (settings.name == '/') {
                  if (AuthService.instance.isLoggedIn.value) {
                    // If logged in, redirect based on role
                    final role = AuthService.instance.userRole.value;
                    switch (role) {
                      case UserRole.admin:
                        return MaterialPageRoute(
                          builder: (_) => const AdminDashboard(),
                          settings: settings,
                        );
                      case UserRole.psychiatrist:
                        return MaterialPageRoute(
                          builder: (_) => const PsychiatristDashboardScreen(),
                          settings: settings,
                        );
                      case UserRole.gp:
                        return MaterialPageRoute(
                          builder: (_) => const GPDashboardScreen(),
                          settings: settings,
                        );
                      case UserRole.pharmacist:
                        return MaterialPageRoute(
                          builder: (_) => const PharmacistDashboardScreen(),
                          settings: settings,
                        );
                      case UserRole.lab_tech:
                        return MaterialPageRoute(
                          builder: (_) => const LabDashboardScreen(),
                          settings: settings,
                        );
                      case UserRole.student:
                      default:
                        return MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                          settings: settings,
                        );
                    }
                  } else {
                    return MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                      settings: settings,
                    );
                  }
                }

                return null;
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
            );
          },
        );
      },
    );
  }
}
