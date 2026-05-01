import 'dart:async';
import 'models.dart';
import 'repository.dart';
import '../models/prescription_model.dart';
import '../pharmacist_dashboard/models.dart';
import '../lab_module/models.dart';

class MockRepository implements DashboardRepository {
  final List<Patient> _patients = [
    Patient(
      id: 'p1',
      name: 'Alice Banda',
      age: 21,
      studentId: 'NUST001',
      summary: 'Anxiety, occasional insomnia.',
    ),
    Patient(
      id: 'p2',
      name: 'Brian Chirwa',
      age: 23,
      studentId: 'NUST002',
      summary: 'Mood swings, past therapy.',
    ),
  ];

  final List<Appointment> _appointments = [
    Appointment(
      id: 'a1',
      patientId: 'p1',
      time: DateTime.now().add(const Duration(hours: 2)),
      status: 'pending',
    ),
    Appointment(
      id: 'a2',
      patientId: 'p2',
      time: DateTime.now().add(const Duration(days: 1)),
      status: 'confirmed',
    ),
  ];

  final List<Note> _notes = [];
  final List<Prescription> _prescriptions = [];
  final List<Vitals> _vitals = [];
  final List<Medication> _medications = [
    Medication(
      id: 'm1',
      name: 'Paracetamol',
      category: 'Painkiller',
      stock: 500,
      unit: 'tablets',
    ),
    Medication(
      id: 'm2',
      name: 'Amoxicillin',
      category: 'Antibiotic',
      stock: 100,
      unit: 'capsules',
    ),
    Medication(
      id: 'm3',
      name: 'Cetirizine',
      category: 'Antihistamine',
      stock: 200,
      unit: 'tablets',
    ),
  ];
  final List<LabRequest> _labRequests = [
    LabRequest(
      id: 'lr1',
      patientId: 'p1',
      patientName: 'Alice Banda',
      doctorName: 'Dr. Smith',
      testType: 'Blood Test - CBC',
      status: 'pending',
      orderedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    LabRequest(
      id: 'lr2',
      patientId: 'p2',
      patientName: 'Brian Chirwa',
      doctorName: 'Dr. Johnson',
      testType: 'Urine Analysis',
      status: 'pending',
      orderedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    LabRequest(
      id: 'lr3',
      patientId: 'p1',
      patientName: 'Alice Banda',
      doctorName: 'Dr. Smith',
      testType: 'X-Ray Chest',
      status: 'completed',
      result: 'Normal chest X-ray. No abnormalities detected.',
      orderedAt: DateTime.now().subtract(const Duration(days: 1)),
      completedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    LabRequest(
      id: 'lr4',
      patientId: 'p2',
      patientName: 'Brian Chirwa',
      doctorName: 'Dr. Johnson',
      testType: 'Blood Glucose Test',
      status: 'completed',
      result: 'Fasting blood glucose: 95 mg/dL (Normal range: 70-100 mg/dL)',
      orderedAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
    LabRequest(
      id: 'lr5',
      patientId: 'p1',
      patientName: 'Alice Banda',
      doctorName: 'Dr. Smith',
      testType: 'Thyroid Function Test',
      status: 'pending',
      orderedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    LabRequest(
      id: 'lr6',
      patientId: 'p2',
      patientName: 'Brian Chirwa',
      doctorName: 'Dr. Johnson',
      testType: 'Liver Function Test',
      status: 'pending',
      orderedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  final _appointmentStream = StreamController<List<Appointment>>.broadcast();
  final _notesStream = StreamController<List<Note>>.broadcast();
  final _prescriptionStream = StreamController<List<Prescription>>.broadcast();
  final _vitalsStream = StreamController<List<Vitals>>.broadcast();
  final _medicationStream = StreamController<List<Medication>>.broadcast();
  final _labRequestStream = StreamController<List<LabRequest>>.broadcast();
  final _adminStatsStream = StreamController<Map<String, dynamic>>.broadcast();

  MockRepository() {
    _emitAppointments();
  }

  void _emitAppointments() =>
      _appointmentStream.add(List<Appointment>.from(_appointments));
  void _emitNotes(String appointmentId) => _notesStream.add(
    _notes.where((n) => n.appointmentId == appointmentId).toList(),
  );
  void _emitPrescriptions() =>
      _prescriptionStream.add(List<Prescription>.from(_prescriptions));
  void _emitVitals(String patientId) => _vitalsStream.add(
    _vitals.where((v) => v.patientId == patientId).toList(),
  );
  void _emitMedications() =>
      _medicationStream.add(List<Medication>.from(_medications));
  void _emitLabRequests() =>
      _labRequestStream.add(List<LabRequest>.from(_labRequests));
  void _emitAdminStats() {
    final stats = {
      'totalAppointments': _appointments.length,
      'pendingAppointments': _appointments
          .where((a) => a.status == 'pending')
          .length,
      'pendingLabs': _labRequests.where((r) => r.status == 'pending').length,
      'pendingPrescriptions': _prescriptions
          .where((p) => p.status == 'pending')
          .length,
      'lowStockMeds': _medications.where((m) => m.stock < 50).length,
      'appointmentTrends': [12, 18, 15, 22, 19, 25, 21], // Mock trend
      'mostCommonReason': 'Flu/Cold (34%)',
    };
    _adminStatsStream.add(stats);
  }

  @override
  Stream<List<Appointment>> fetchAppointments() {
    Timer.run(() => _emitAppointments());
    return _appointmentStream.stream;
  }

  @override
  Stream<List<Appointment>> fetchAppointmentsForDay(DateTime day) {
    Timer.run(() => _emitAppointments());
    return _appointmentStream.stream.map((list) {
      return list.where((a) {
        return a.time.year == day.year &&
            a.time.month == day.month &&
            a.time.day == day.day;
      }).toList();
    });
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    try {
      return Future.value(_patients.firstWhere((p) => p.id == id));
    } catch (_) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx == -1) return Future.value(false);
    _appointments[idx] = Appointment(
      id: _appointments[idx].id,
      patientId: _appointments[idx].patientId,
      time: _appointments[idx].time,
      status: status,
    );
    _emitAppointments();
    return Future.value(true);
  }

  @override
  Stream<List<Note>> fetchNotesStream(String appointmentId) {
    Timer.run(
      () => _emitNotes(appointmentId),
    ); // Emit current notes immediately
    return _notesStream.stream.where(
      (list) => list.isEmpty || list.first.appointmentId == appointmentId,
    );
  }

  @override
  Future<Note> addNote(String appointmentId, String text) async {
    final note = Note(
      id: 'n${_notes.length + 1}',
      appointmentId: appointmentId,
      text: text,
      createdAt: DateTime.now(),
    );
    _notes.add(note);
    _emitNotes(appointmentId);
    return Future.value(note);
  }

  @override
  Future<bool> updateNote(String noteId, String newText) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      final oldNote = _notes[index];
      _notes[index] = Note(
        id: noteId,
        appointmentId: oldNote.appointmentId,
        text: newText,
        createdAt: oldNote.createdAt,
      );
      _emitNotes(oldNote.appointmentId);
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteNote(String noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      final apptId = _notes[index].appointmentId;
      _notes.removeAt(index);
      _emitNotes(apptId);
      return true;
    }
    return false;
  }

  @override
  Future<List<Appointment>> fetchPatientHistory(String patientId) async {
    // Return all appointments for this patient, but only those in the past or completed
    return Future.value(
      _appointments.where((a) => a.patientId == patientId).toList(),
    );
  }

  @override
  Future<List<Note>> fetchAllNotesByPatient(String patientId) async {
    return _notes
        .where(
          (n) => _appointments.any(
            (a) => a.id == n.appointmentId && a.patientId == patientId,
          ),
        )
        .toList();
  }

  // Student Booking Methods
  @override
  Future<bool> createAppointment(Appointment appointment) async {
    _appointments.add(appointment);
    _emitAppointments();
    return true;
  }

  @override
  Stream<List<Appointment>> fetchAppointmentsForStudent(String patientId) {
    return _appointmentStream.stream.map((list) {
      return list.where((a) => a.patientId == patientId).toList();
    });
  }

  @override
  Future<List<DateTime>> fetchAvailableSlots(DateTime day) async {
    // Generate slots: 09:00 to 16:00, 30 min intervals
    List<DateTime> slots = [];
    DateTime start = DateTime(day.year, day.month, day.day, 9, 0);
    DateTime end = DateTime(day.year, day.month, day.day, 16, 0);

    while (start.isBefore(end)) {
      // Check if already booked
      final isBooked = _appointments.any(
        (a) =>
            a.time.year == start.year &&
            a.time.month == start.month &&
            a.time.day == start.day &&
            a.time.hour == start.hour &&
            a.time.minute == start.minute,
      );

      if (!isBooked) {
        slots.add(start);
      }
      start = start.add(const Duration(minutes: 30));
    }
    return slots;
  }

  // Prescription Methods
  @override
  Future<bool> addPrescription(Prescription prescription) async {
    _prescriptions.add(prescription);
    _emitPrescriptions();
    return true;
  }

  @override
  Stream<List<Prescription>> fetchPrescriptionsForPatient(String patientId) {
    Timer.run(() => _emitPrescriptions());
    return _prescriptionStream.stream.map((list) {
      return list.where((p) => p.patientId == patientId).toList();
    });
  }

  @override
  Future<bool> updatePrescriptionStatus(
    String prescriptionId,
    String status,
  ) async {
    final idx = _prescriptions.indexWhere((p) => p.id == prescriptionId);
    if (idx == -1) return false;
    final old = _prescriptions[idx];
    _prescriptions[idx] = Prescription(
      id: old.id,
      patientId: old.patientId,
      patientName: old.patientName,
      doctorName: old.doctorName,
      medication: old.medication,
      dosage: old.dosage,
      instructions: old.instructions,
      date: old.date,
      status: status,
    );
    _emitPrescriptions();
    return true;
  }

  @override
  Stream<List<Prescription>> fetchAllPrescriptions() {
    Timer.run(() => _emitPrescriptions());
    return _prescriptionStream.stream;
  }

  // Vitals Methods
  @override
  Future<bool> addVitals(Vitals vitals) async {
    _vitals.add(vitals);
    _emitVitals(vitals.patientId);
    return true;
  }

  @override
  Stream<List<Vitals>> fetchVitals(String patientId) {
    Timer.run(() => _emitVitals(patientId));
    return _vitalsStream.stream.where(
      (list) => list.isEmpty || list.first.patientId == patientId,
    );
  }

  @override
  Stream<List<Medication>> fetchInventory() {
    Timer.run(() => _emitMedications());
    return _medicationStream.stream;
  }

  @override
  Future<bool> updateInventoryStock(String medicationId, int newStock) async {
    final idx = _medications.indexWhere((m) => m.id == medicationId);
    if (idx == -1) return false;
    _medications[idx] = Medication(
      id: medicationId,
      name: _medications[idx].name,
      category: _medications[idx].category,
      stock: newStock,
      unit: _medications[idx].unit,
    );
    _emitMedications();
    return true;
  }

  // Lab Methods
  @override
  Future<bool> addLabRequest(LabRequest request) async {
    _labRequests.add(request);
    _emitLabRequests();
    return true;
  }

  @override
  Stream<List<LabRequest>> fetchLabRequests() {
    Timer.run(() => _emitLabRequests());
    return _labRequestStream.stream;
  }

  @override
  Future<bool> updateLabResult(String id, String result) async {
    final idx = _labRequests.indexWhere((r) => r.id == id);
    if (idx == -1) return false;
    final old = _labRequests[idx];
    _labRequests[idx] = LabRequest(
      id: old.id,
      patientId: old.patientId,
      patientName: old.patientName,
      doctorName: old.doctorName,
      testType: old.testType,
      status: 'completed',
      result: result,
      orderedAt: old.orderedAt,
      completedAt: DateTime.now(),
    );
    _emitLabRequests();
    return true;
  }

  @override
  Stream<List<LabRequest>> fetchLabRequestsForPatient(String patientId) {
    Timer.run(() => _emitLabRequests());
    return _labRequestStream.stream.map(
      (list) => list.where((r) => r.patientId == patientId).toList(),
    );
  }

  @override
  Stream<Map<String, dynamic>> fetchAdminStats() {
    Timer.run(() => _emitAdminStats());
    return _adminStatsStream.stream;
  }
}

// Initialize default repository to mock implementation.
void initMockRepository() {
  repository = MockRepository();
}
