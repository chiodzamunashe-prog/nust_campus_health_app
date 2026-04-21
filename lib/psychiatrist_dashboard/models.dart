import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String studentId;
  final String summary;

  Patient({required this.id, required this.name, required this.age, required this.studentId, this.summary = ''});
}

class Appointment {
  final String id;
  final String patientId;
  final DateTime time;
  final String status; // e.g., pending, confirmed, completed

  Appointment({required this.id, required this.patientId, required this.time, this.status = 'pending'});

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      time: (data['time'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }
}

class Note {
  final String id;
  final String appointmentId;
  final String text;
  final DateTime createdAt;

  Note({required this.id, required this.appointmentId, required this.text, required this.createdAt});
}
