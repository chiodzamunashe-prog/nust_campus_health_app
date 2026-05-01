import 'package:cloud_firestore/cloud_firestore.dart';

class LabRequest {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorName;
  final String testType;
  final String status; // 'pending', 'completed'
  final String result;
  final DateTime orderedAt;
  final DateTime? completedAt;

  LabRequest({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.testType,
    this.status = 'pending',
    this.result = '',
    required this.orderedAt,
    this.completedAt,
  });

  factory LabRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LabRequest(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorName: data['doctorName'] ?? '',
      testType: data['testType'] ?? '',
      status: data['status'] ?? 'pending',
      result: data['result'] ?? '',
      orderedAt: (data['orderedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorName': doctorName,
      'testType': testType,
      'status': status,
      'result': result,
      'orderedAt': Timestamp.fromDate(orderedAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }
}
