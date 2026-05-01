import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'repository.dart';
import '../models/prescription_model.dart';
import '../pharmacist_dashboard/models.dart';
import '../lab_module/models.dart';

class FirestoreRepository implements DashboardRepository {
  final FirebaseFirestore _db;

  FirestoreRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Note> addNote(String appointmentId, String text) async {
    final doc = await _db.collection('notes').add({
      'appointmentId': appointmentId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return Note(
      id: doc.id,
      appointmentId: appointmentId,
      text: text,
      createdAt: DateTime.now(),
    );
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
    return Patient(
      id: snap.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      studentId: data['studentId'] ?? '',
      summary: data['summary'] ?? '',
    );
  }

  @override
  Stream<List<Note>> fetchNotesStream(String appointmentId) {
    return _db
        .collection('notes')
        .where('appointmentId', isEqualTo: appointmentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (q) => q.docs
              .map(
                (d) => Note(
                  id: d.id,
                  appointmentId: d['appointmentId'],
                  text: d['text'],
                  createdAt:
                      (d['createdAt'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<List<Appointment>> fetchAppointments() {
    return _db.collection('appointments').snapshots().map((snapshot) {
      return snapshot.docs
          .map<Appointment>((doc) => Appointment.fromFirestore(doc))
          .toList();
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
          return snapshot.docs
              .map<Appointment>((doc) => Appointment.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<bool> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      await _db.collection('appointments').doc(appointmentId).update({
        'status': status,
      });
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
        .map(
          (d) => Appointment(
            id: d.id,
            patientId: d['patientId'],
            time: (d['time'] as Timestamp).toDate(),
            status: d['status'] ?? 'pending',
          ),
        )
        .toList();
  }

  @override
  Future<List<Note>> fetchAllNotesByPatient(String patientId) async {
    final appointments = await _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .get();
    if (appointments.docs.isEmpty) return [];

    final apptIds = appointments.docs.map((d) => d.id).toList();
    final notes = await _db.collection('notes').get();
    return notes.docs
        .where((d) => apptIds.contains(d['appointmentId']))
        .map(
          (d) => Note(
            id: d.id,
            appointmentId: d['appointmentId'],
            text: d['text'],
            createdAt: (d['createdAt'] as Timestamp).toDate(),
          ),
        )
        .toList();
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
        .map(
          (s) => s.docs
              .map<Appointment>((d) => Appointment.fromFirestore(d))
              .toList(),
        );
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

    final bookedTimes = snapshot.docs
        .map((d) => (d['time'] as Timestamp).toDate())
        .toList();

    List<DateTime> slots = [];
    DateTime current = DateTime(day.year, day.month, day.day, 9, 0);
    DateTime limit = DateTime(day.year, day.month, day.day, 16, 0);

    while (current.isBefore(limit)) {
      final isBooked = bookedTimes.any(
        (bt) => bt.hour == current.hour && bt.minute == current.minute,
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

  @override
  Future<bool> updatePrescriptionStatus(
    String prescriptionId,
    String status,
  ) async {
    try {
      await _db.collection('prescriptions').doc(prescriptionId).update({
        'status': status,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<Prescription>> fetchAllPrescriptions() {
    return _db
        .collection('prescriptions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Prescription.fromFirestore(d)).toList());
  }

  // Vitals Methods
  @override
  Future<bool> addVitals(Vitals vitals) async {
    try {
      await _db.collection('vitals').add(vitals.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<Vitals>> fetchVitals(String patientId) {
    return _db
        .collection('vitals')
        .where('patientId', isEqualTo: patientId)
        .orderBy('recordedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Vitals.fromFirestore(d)).toList());
  }

  @override
  Stream<List<Medication>> fetchInventory() {
    return _db.collection('inventory').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Medication.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<bool> updateInventoryStock(String medicationId, int newStock) async {
    try {
      await _db.collection('inventory').doc(medicationId).update({
        'stock': newStock,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Lab Methods
  @override
  Future<bool> addLabRequest(LabRequest request) async {
    try {
      await _db.collection('lab_requests').add(request.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<LabRequest>> fetchLabRequests() {
    return _db
        .collection('lab_requests')
        .orderBy('orderedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => LabRequest.fromFirestore(d)).toList());
  }

  @override
  Future<bool> updateLabResult(String id, String result) async {
    try {
      await _db.collection('lab_requests').doc(id).update({
        'result': result,
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<LabRequest>> fetchLabRequestsForPatient(String patientId) {
    return _db
        .collection('lab_requests')
        .where('patientId', isEqualTo: patientId)
        .orderBy('orderedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => LabRequest.fromFirestore(d)).toList());
  }

  @override
  Stream<Map<String, dynamic>> fetchAdminStats() {
    // Combine multiple collection snapshots into a single stats map
    return Rx.combineLatest5(
      _db.collection('appointments').snapshots(),
      _db.collection('lab_requests').snapshots(),
      _db.collection('prescriptions').snapshots(),
      _db.collection('inventory').snapshots(),
      _db.collection('patients').snapshots(),
      (
        QuerySnapshot appts,
        QuerySnapshot labs,
        QuerySnapshot presc,
        QuerySnapshot inv,
        QuerySnapshot patients,
      ) {
        return {
          'totalAppointments': appts.size,
          'pendingAppointments': appts.docs
              .where((d) => d['status'] == 'pending')
              .length,
          'pendingLabs': labs.docs
              .where((d) => d['status'] == 'pending')
              .length,
          'pendingPrescriptions': presc.docs
              .where((d) => d['status'] == 'pending')
              .length,
          'lowStockMeds': inv.docs.where((d) => d['stock'] < 50).length,
          'totalPatients': patients.size,
          'appointmentTrends': [
            10,
            15,
            12,
            20,
            18,
            22,
            19,
          ], // Placeholder for actual time-series logic
        };
      },
    );
  }
}

// Helper class for combining streams (requires rxdart)
class Rx {
  static Stream<R> combineLatest5<T1, T2, T3, T4, T5, R>(
    Stream<T1> s1,
    Stream<T2> s2,
    Stream<T3> s3,
    Stream<T4> s4,
    Stream<T5> s5,
    R Function(T1, T2, T3, T4, T5) combiner,
  ) {
    late StreamController<R> controller;
    controller = StreamController<R>.broadcast(
      onListen: () {
        T1? v1;
        T2? v2;
        T3? v3;
        T4? v4;
        T5? v5;
        bool b1 = false, b2 = false, b3 = false, b4 = false, b5 = false;

        void update() {
          if (b1 && b2 && b3 && b4 && b5) {
            controller.add(
              combiner(v1 as T1, v2 as T2, v3 as T3, v4 as T4, v5 as T5),
            );
          }
        }

        s1.listen((v) {
          v1 = v;
          b1 = true;
          update();
        });
        s2.listen((v) {
          v2 = v;
          b2 = true;
          update();
        });
        s3.listen((v) {
          v3 = v;
          b3 = true;
          update();
        });
        s4.listen((v) {
          v4 = v;
          b4 = true;
          update();
        });
        s5.listen((v) {
          v5 = v;
          b5 = true;
          update();
        });
      },
    );
    return controller.stream;
  }
}
