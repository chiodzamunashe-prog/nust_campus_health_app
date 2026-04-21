import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'repository.dart';
import '../models/prescription_model.dart';

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
    return Note(id: doc.id, appointmentId: appointmentId, text: text, createdAt: DateTime.now());
  }

  @override
  Future<bool> updateNote(String noteId, String newText) async {
    try {
      await _db.collection('notes').doc(noteId).update({'text': newText});
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteNote(String noteId) async {
    try {
      await _db.collection('notes').doc(noteId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    final snap = await _db.collection('patients').doc(id).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    return Patient(id: snap.id, name: data['name'] ?? '', age: data['age'] ?? 0, studentId: data['studentId'] ?? '', summary: data['summary'] ?? '');
  }

  @override
  Stream<List<Note>> fetchNotesStream(String appointmentId) {
    return _db
        .collection('notes')
        .where('appointmentId', isEqualTo: appointmentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((q) => q.docs
            .map((d) => Note(
                id: d.id,
                appointmentId: d['appointmentId'],
                text: d['text'],
                createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()))
            .toList());
  }

  @override
  Stream<List<Appointment>> fetchAppointments() {
    return _db.collection('appointments').snapshots().map((snapshot) {
      return snapshot.docs.map<Appointment>((doc) => Appointment.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<Appointment>> fetchAppointmentsForDay(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

    return _db
        .collection('appointments')
        .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('time', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map<Appointment>((doc) => Appointment.fromFirestore(doc)).toList();
    });
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

  @override
  Future<List<Appointment>> fetchPatientHistory(String patientId) async {
    final q = await _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('time', descending: true)
        .get();
    return q.docs
        .map((d) => Appointment(
            id: d.id,
            patientId: d['patientId'],
            time: (d['time'] as Timestamp).toDate(),
            status: d['status'] ?? 'pending'))
        .toList();
  }

  @override
  Future<List<Note>> fetchAllNotesByPatient(String patientId) async {
    final appointments = await _db.collection('appointments').where('patientId', isEqualTo: patientId).get();
    if (appointments.docs.isEmpty) return [];
    
    final apptIds = appointments.docs.map((d) => d.id).toList();
    final notes = await _db.collection('notes').get();
    return notes.docs
      .where((d) => apptIds.contains(d['appointmentId']))
      .map((d) => Note(
        id: d.id,
        appointmentId: d['appointmentId'],
        text: d['text'],
        createdAt: (d['createdAt'] as Timestamp).toDate(),
      )).toList();
  }

  @override
  Future<bool> createAppointment(Appointment appointment) async {
    await _db.collection('appointments').add({
      'patientId': appointment.patientId,
      'time': Timestamp.fromDate(appointment.time),
      'status': appointment.status,
    });
    return true;
  }

  @override
  Stream<List<Appointment>> fetchAppointmentsForStudent(String patientId) {
    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((s) => s.docs.map<Appointment>((d) => Appointment.fromFirestore(d)).toList());
  }

  @override
  Future<List<DateTime>> fetchAvailableSlots(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day, 0, 0);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59);

    final snapshot = await _db
        .collection('appointments')
        .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('time', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    final bookedTimes = snapshot.docs.map((d) => (d['time'] as Timestamp).toDate()).toList();

    List<DateTime> slots = [];
    DateTime current = DateTime(day.year, day.month, day.day, 9, 0);
    DateTime limit = DateTime(day.year, day.month, day.day, 16, 0);

    while (current.isBefore(limit)) {
      final isBooked = bookedTimes.any((bt) => 
        bt.hour == current.hour && bt.minute == current.minute
      );
      if (!isBooked) slots.add(current);
      current = current.add(const Duration(minutes: 30));
    }
    return slots;
  }

  // Prescription Methods
  @override
  Future<bool> addPrescription(Prescription prescription) async {
    await _db.collection('prescriptions').add(prescription.toMap());
    return true;
  }

  @override
  Stream<List<Prescription>> fetchPrescriptionsForPatient(String patientId) {
    return _db
        .collection('prescriptions')
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Prescription.fromFirestore(d)).toList());
  }
}
