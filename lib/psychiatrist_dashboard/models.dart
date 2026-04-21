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
  final String type; // 'psychiatry', 'general'

  Note({
    required this.id,
    required this.appointmentId,
    required this.text,
    required this.createdAt,
    this.type = 'general',
  });
}

class Vitals {
  final String id;
  final String patientId;
  final String bloodPressure;
  final double temperature;
  final int heartRate;
  final double weight;
  final DateTime recordedAt;

  Vitals({
    required this.id,
    required this.patientId,
    required this.bloodPressure,
    required this.temperature,
    required this.heartRate,
    required this.weight,
    required this.recordedAt,
  });

  factory Vitals.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vitals(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      bloodPressure: data['bloodPressure'] ?? '',
      temperature: (data['temperature'] ?? 0.0).toDouble(),
      heartRate: data['heartRate'] ?? 0,
      weight: (data['weight'] ?? 0.0).toDouble(),
      recordedAt: (data['recordedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'bloodPressure': bloodPressure,
      'temperature': temperature,
      'heartRate': heartRate,
      'weight': weight,
      'recordedAt': Timestamp.fromDate(recordedAt),
    };
  }
}
