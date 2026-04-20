import 'package:flutter/material.dart';
import 'models.dart';
import 'mock_service.dart';
import 'patient_summary_screen.dart';

class PsychiatristDashboardScreen extends StatefulWidget {
  const PsychiatristDashboardScreen({super.key});

  @override
  State<PsychiatristDashboardScreen> createState() => _PsychiatristDashboardScreenState();
}

class _PsychiatristDashboardScreenState extends State<PsychiatristDashboardScreen> {
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = MockService.fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Psychiatrist Dashboard')),
      body: FutureBuilder<List<Appointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final appointments = snapshot.data ?? [];
          if (appointments.isEmpty) return const Center(child: Text('No appointments'));

          return ListView.separated(
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final appt = appointments[index];
              return FutureBuilder<Patient?>(
                future: MockService.getPatientById(appt.patientId),
                builder: (c, psnap) {
                  final patient = psnap.data;
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(patient?.name ?? 'Unknown'),
                    subtitle: Text('${appt.time} • ${appt.status}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (patient != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PatientSummaryScreen(patient: patient)));
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
