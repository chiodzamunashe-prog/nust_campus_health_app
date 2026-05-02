import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecord {
  final String id;
  final String patientId;
  final String patientName;
  final String studentId;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<VisitSummary> visitHistory;
  final DateTime lastUpdated;

  MedicalRecord({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.studentId,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.visitHistory = const [],
    required this.lastUpdated,
  });

  factory MedicalRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicalRecord(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      studentId: data['studentId'] ?? '',
      allergies: List<String>.from(data['allergies'] ?? []),
      chronicConditions: List<String>.from(data['chronicConditions'] ?? []),
      visitHistory: (data['visitHistory'] as List? ?? [])
          .map((v) => VisitSummary.fromMap(v as Map<String, dynamic>))
          .toList(),
      lastUpdated: data['lastUpdated'] != null 
          ? (data['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'studentId': studentId,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'visitHistory': visitHistory.map((v) => v.toMap()).toList(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

class VisitSummary {
  final String id;
  final String doctorName;
  final DateTime date;
  final String diagnosis;
  final String treatment;
  final String notes;

  VisitSummary({
    required this.id,
    required this.doctorName,
    required this.date,
    required this.diagnosis,
    this.treatment = '',
    this.notes = '',
  });

  factory VisitSummary.fromMap(Map<String, dynamic> map) {
    return VisitSummary(
      id: map['id'] ?? '',
      doctorName: map['doctorName'] ?? '',
      date: map['date'] != null 
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      diagnosis: map['diagnosis'] ?? '',
      treatment: map['treatment'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'date': Timestamp.fromDate(date),
      'diagnosis': diagnosis,
      'treatment': treatment,
      'notes': notes,
    };
  }
}
