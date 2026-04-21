import 'package:cloud_firestore/cloud_firestore.dart';

class Prescription {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorName;
  final String medication;
  final String dosage;
  final String instructions;
  final DateTime date;
  final String status; // 'pending', 'dispensed'

  Prescription({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.medication,
    required this.dosage,
    required this.instructions,
    required this.date,
    this.status = 'pending',
  });

  factory Prescription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Prescription(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorName: data['doctorName'] ?? '',
      medication: data['medication'] ?? '',
      dosage: data['dosage'] ?? '',
      instructions: data['instructions'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorName': doctorName,
      'medication': medication,
      'dosage': dosage,
      'instructions': instructions,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }
}
