import 'package:flutter/material.dart';
import '../models/prescription_model.dart';
import '../psychiatrist_dashboard/repository.dart';
import '../auth/auth_service.dart';

class StudentPrescriptionsScreen extends StatelessWidget {
  const StudentPrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = AuthService.instance.currentUser ?? 'student_1';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prescriptions'),
      ),
      body: StreamBuilder<List<Prescription>>(
        stream: repository.fetchPrescriptionsForPatient(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final prescriptions = snapshot.data ?? [];

          if (prescriptions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication_liquid, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No prescriptions found.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: prescriptions.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final p = prescriptions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              p.medication,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003366),
                              ),
                            ),
                          ),
                          Text(
                            '${p.date.day}/${p.date.month}/${p.date.year}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.medical_services, size: 16, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(p.doctorName, style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                      const Divider(height: 24),
                      Text('Dosage:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                      Text(p.dosage, style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 12),
                      Text('Instructions:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                      Text(p.instructions, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
