import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

abstract class RecordsRepository {
  Stream<MedicalRecord?> fetchMedicalRecord(String patientId);
  Future<void> updateMedicalRecord(MedicalRecord record);
}

class FirestoreRecordsRepository implements RecordsRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Stream<MedicalRecord?> fetchMedicalRecord(String patientId) {
    return _firestore
        .collection('medical_records')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return MedicalRecord.fromFirestore(snapshot.docs.first);
    });
  }

  @override
  Future<void> updateMedicalRecord(MedicalRecord record) async {
    await _firestore
        .collection('medical_records')
        .doc(record.id)
        .set(record.toMap());
  }
}

class MockRecordsRepository implements RecordsRepository {
  @override
  Stream<MedicalRecord?> fetchMedicalRecord(String patientId) {
    return Stream.value(
      MedicalRecord(
        id: 'mock_record_1',
        patientId: patientId,
        patientName: 'Zamazane Chiodza',
        studentId: '202100123',
        allergies: ['Peanuts', 'Penicillin'],
        chronicConditions: ['Asthma'],
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        visitHistory: [
          VisitSummary(
            id: 'v1',
            doctorName: 'Dr. Smith',
            date: DateTime.now().subtract(const Duration(days: 10)),
            diagnosis: 'Seasonal Allergies',
            treatment: 'Antihistamines',
            notes: 'Patient responded well to treatment.',
          ),
          VisitSummary(
            id: 'v2',
            doctorName: 'Dr. Brown',
            date: DateTime.now().subtract(const Duration(days: 45)),
            diagnosis: 'Common Cold',
            treatment: 'Rest and Fluids',
            notes: 'Advised to return if symptoms persist.',
          ),
        ],
      ),
    );
  }

  @override
  Future<void> updateMedicalRecord(MedicalRecord record) async {
    // Mock update
    print('Mock update for record ${record.id}');
  }
}

// Global instance to be initialized in main.dart
late RecordsRepository recordsRepository;

void initMockRecordsRepository() {
  recordsRepository = MockRecordsRepository();
}
