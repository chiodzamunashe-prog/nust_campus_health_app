import 'package:flutter/material.dart';
import 'models.dart';

class PatientSummaryScreen extends StatelessWidget {
  final Patient patient;

  const PatientSummaryScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(patient.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student ID: ${patient.studentId}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Age: ${patient.age}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text('Summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(patient.summary),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Placeholder: accept consult
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consult accepted (mock)')));
              },
              icon: const Icon(Icons.check),
              label: const Text('Accept Consult'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                // Placeholder: decline consult
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consult declined (mock)')));
              },
              icon: const Icon(Icons.close),
              label: const Text('Decline Consult'),
            ),
          ],
        ),
      ),
    );
  }
}
