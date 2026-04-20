import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'repository.dart';

class FirestoreRepository implements DashboardRepository {
  final FirebaseFirestore _db;

  FirestoreRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Note> addNote(String appointmentId, String text) async {
    final doc = await _db.collection('notes').add({
      'appointmentId': appointmentId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final snap = await doc.get();
    return Note(id: doc.id, appointmentId: appointmentId, text: text, createdAt: DateTime.now());
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    final snap = await _db.collection('patients').doc(id).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    return Patient(id: snap.id, name: data['name'] ?? '', age: data['age'] ?? 0, studentId: data['studentId'] ?? '', summary: data['summary'] ?? '');
  }

  @override
  Future<List<Note>> fetchNotesByAppointment(String appointmentId) async {
    final q = await _db.collection('notes').where('appointmentId', isEqualTo: appointmentId).orderBy('createdAt', descending: false).get();
    return q.docs.map((d) => Note(id: d.id, appointmentId: d['appointmentId'], text: d['text'], createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now())).toList();
  }

  @override
  Future<List<Appointment>> fetchAppointments() async {
    final q = await _db.collection('appointments').orderBy('time').get();
    return q.docs.map((d) => Appointment(id: d.id, patientId: d['patientId'], time: (d['time'] as Timestamp).toDate(), status: d['status'] ?? 'pending')).toList();
  }

  @override
  Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _db.collection('appointments').doc(appointmentId).update({'status': status});
      return true;
    } catch (e) {
      return false;
    }
  }
}
