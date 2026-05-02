import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/auth_service.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'home/home_screen.dart';
import 'appointments/my_appointments_screen.dart';
import 'appointments/booking_screen.dart';
import 'prescriptions/student_prescriptions_screen.dart';
import 'prescriptions/prescription_form_screen.dart';
import 'pharmacist_dashboard/dashboard_screen.dart';
import 'pharmacist_dashboard/dispense_detail_screen.dart';
import 'pharmacist_dashboard/models.dart' as pharm_models;
import 'gp_dashboard/dashboard_screen.dart';
import 'gp_dashboard/patient_summary_screen.dart' as gp_summary;
import 'gp_dashboard/vitals_form.dart';
import 'gp_dashboard/gp_consultation_form.dart';
import 'gp_dashboard/gp_medical_certificate_form.dart';
import 'lab_module/dashboard_screen.dart';
import 'lab_module/result_entry_screen.dart';
import 'lab_module/models.dart';
import 'emergency/emergency_hub_screen.dart';
import 'notifications/notifications_screen.dart';
import 'notifications/notification_service.dart';
import 'chat/chat_list_screen.dart';
import 'admin/ui/admin_dashboard.dart';
import 'admin/repository/admin_repository.dart';
import 'psychiatrist_dashboard/dashboard_screen.dart';
import 'psychiatrist_dashboard/patient_summary_screen.dart' as psy_summary;
import 'psychiatrist_dashboard/models.dart' as psy_models;
import 'psychiatrist_dashboard/repository.dart';
import 'psychiatrist_dashboard/mock_repository.dart';
import 'psychiatrist_dashboard/firestore_repository.dart';
import 'records/record.dart';
import 'records/repository.dart';
import 'records/models.dart';
import 'chat/repository.dart';
import 'chat/firestore_repository.dart' as chat_firestore;
import 'chat/mock_repository.dart' as chat_mock;
import 'notifications/repository.dart' as notif_repo;
import 'notifications/firestore_repository.dart' as notif_firestore;
import 'notifications/mock_repository.dart' as notif_mock;
import 'models/prescription_model.dart';
import 'firebase_options.dart';
import 'counselling/counselling.dart';

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
    final firebaseReady = await _initializeFirebase();

    if (firebaseReady) {
      try {
        repository = FirestoreRepository();
        chatRepository = chat_firestore.FirestoreChatRepository();
        recordsRepository = FirestoreRecordsRepository();
      } catch (_) {
        initMockRepository();
        chat_mock.initMockChatRepository();
        initMockRecordsRepository();
      }
      initAdminMockRepository();
    } else {
      initMockRepository();
      chat_mock.initMockChatRepository();
      initAdminMockRepository();
      initMockRecordsRepository();
    }

    await AppNotificationService.instance.initialize(
      enableRemoteMessaging: false,
    );

    AuthService.instance.init();

    return true;
  }

  Future<bool> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return true;
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      return false;
    }
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
                  final patient = settings.arguments as psy_models.Patient;
                  return MaterialPageRoute(
                    builder: (_) => PrescriptionFormScreen(patient: patient),
                    settings: settings,
                  );
                }

                if (settings.name == '/pharmacist_dashboard') {
                  return MaterialPageRoute(
                    builder: (_) => const PharmacistDashboardScreen(),
                    settings: settings,
                  );
                }

                if (settings.name == '/dispense_detail') {
                  final prescription = settings.arguments as Prescription;
                  return MaterialPageRoute(
                    builder: (_) =>
                        DispenseDetailScreen(prescription: prescription),
                    settings: settings,
                  );
                }

                if (settings.name == '/gp_dashboard') {
                  return MaterialPageRoute(
                    builder: (_) => const GPDashboardScreen(),
                    settings: settings,
                  );
                }

                if (settings.name == '/patient_summary') {
                  final args = settings.arguments as Map<String, dynamic>;
                  final patient = args['patient'] as psy_models.Patient;
                  final appointmentId = args['appointmentId'] as String;
                  return MaterialPageRoute(
                    builder: (_) => gp_summary.GPPatientSummaryScreen(
                      patient: patient,
                      appointmentId: appointmentId,
                    ),
                    settings: settings,
                  );
                }

                if (settings.name == '/vitals_form') {
                  final patientId = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (_) => VitalsForm(patientId: patientId),
                    settings: settings,
                  );
                }

                if (settings.name == '/lab_dashboard') {
                  return MaterialPageRoute(
                    builder: (_) => const LabDashboardScreen(),
                    settings: settings,
                  );
                }

                if (settings.name == '/lab_result_entry') {
                  final request = settings.arguments as LabRequest;
                  return MaterialPageRoute(
                    builder: (_) => LabResultEntryScreen(request: request),
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
                  return MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                    settings: settings,
                  );
                }

                if (settings.name == '/admin') {
                  return MaterialPageRoute(
                    builder: (_) => const AdminDashboard(),
                    settings: settings,
                  );
                }

                if (settings.name == '/psy_dashboard') {
                  return MaterialPageRoute(
                    builder: (_) => const PsychiatristDashboardScreen(),
                    settings: settings,
                  );
                }

                if (settings.name == '/psy_patient_summary') {
                  final args = settings.arguments as Map<String, dynamic>;
                  final patient = args['patient'] as psy_models.Patient;
                  final appointmentId = args['appointmentId'] as String;
                  return MaterialPageRoute(
                    builder: (_) => psy_summary.PatientSummaryScreen(
                      patient: patient,
                      appointmentId: appointmentId,
                    ),
                    settings: settings,
                  );
                }

                if (settings.name == '/counselling') {
                  return MaterialPageRoute(
                    builder: (_) => const CounsellingScreen(),
                    settings: settings,
                  );
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
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  centerTitle: true,
                  backgroundColor: Color(0xFF003366),
                  foregroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
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
              ),
              routes: {
                '/': (context) => const HomeScreen(),
                '/login': (context) => const LoginScreen(),
                '/register': (context) => const RegisterScreen(),
              },
            );
          },
        );
      },
    );
  }
}
