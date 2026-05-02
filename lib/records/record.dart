import 'package:flutter/material.dart';
import 'models.dart';
import 'repository.dart';
import '../auth/auth_service.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using current user ID from auth service
    final patientId = AuthService.instance.currentUser ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<MedicalRecord?>(
        stream: recordsRepository.fetchMedicalRecord(patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final record = snapshot.data;

          if (record == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No medical records found.'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(record),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.history, color: Color(0xFF1565C0)),
                    SizedBox(width: 8),
                    Text(
                      'Session History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (record.visitHistory.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No previous visits recorded.')),
                  )
                else
                  ...record.visitHistory.map((visit) => _buildVisitTile(visit)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(MedicalRecord record) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    record.patientName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ID: ${record.studentId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoSection('Allergies', record.allergies, Colors.red),
            const SizedBox(height: 16),
            _buildInfoSection('Chronic Conditions', record.chronicConditions, Colors.orange),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.update, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Last Updated: ${_formatDate(record.lastUpdated)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.isEmpty
              ? [const Text('None reported', style: TextStyle(fontStyle: FontStyle.italic))]
              : items.map((item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                )).toList(),
        ),
      ],
    );
  }

  Widget _buildVisitTile(VisitSummary visit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE3F2FD),
          child: Icon(Icons.medical_services, color: Color(0xFF1565C0), size: 20),
        ),
        title: Text(
          visit.diagnosis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Dr. ${visit.doctorName} • ${_formatDate(visit.date)}'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _buildDetailRow('Treatment', visit.treatment),
                const SizedBox(height: 10),
                _buildDetailRow('Notes', visit.notes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? 'N/A' : value,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
