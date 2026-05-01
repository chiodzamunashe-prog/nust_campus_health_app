import 'package:flutter/material.dart';
import '../psychiatrist_dashboard/models.dart';
import '../psychiatrist_dashboard/repository.dart';
import '../auth/auth_service.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = AuthService.instance.currentUser ?? 'student_1';

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: StreamBuilder<List<Appointment>>(
        stream: repository.fetchAppointmentsForStudent(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const Center(child: Text('You have no appointments yet.'));
          }

          // Sort by time (nearest first)
          appointments.sort((a, b) => a.time.compareTo(b.time));

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appt = appointments[index];
              final isPast = appt.time.isBefore(DateTime.now());

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.calendar_today,
                    color: isPast ? Colors.grey : const Color(0xFF003366),
                  ),
                  title: Text(
                    '${appt.time.day}/${appt.time.month}/${appt.time.year} at ${appt.time.hour.toString().padLeft(2, '0')}:${appt.time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPast ? Colors.grey : Colors.black,
                    ),
                  ),
                  subtitle: Text('Consultation with Psychiatrist'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(appt.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appt.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(appt.status),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Trigger booking from here too or just use home screen
          Navigator.pushNamed(context, '/book_appointment');
        },
        backgroundColor: const Color(0xFF003366),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
