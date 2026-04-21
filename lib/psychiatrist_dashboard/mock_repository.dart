import 'dart:async';
import 'models.dart';
import 'repository.dart';
import '../models/prescription_model.dart';

class MockRepository implements DashboardRepository {
  final List<Patient> _patients = [
    Patient(id: 'p1', name: 'Alice Banda', age: 21, studentId: 'NUST001', summary: 'Anxiety, occasional insomnia.'),
    Patient(id: 'p2', name: 'Brian Chirwa', age: 23, studentId: 'NUST002', summary: 'Mood swings, past therapy.'),
  ];

  final List<Appointment> _appointments = [
    Appointment(id: 'a1', patientId: 'p1', time: DateTime.now().add(const Duration(hours: 2)), status: 'pending'),
    Appointment(id: 'a2', patientId: 'p2', time: DateTime.now().add(const Duration(days: 1)), status: 'confirmed'),
  ];

  final List<Note> _notes = [];
  final List<Prescription> _prescriptions = [];

  final _appointmentStream = StreamController<List<Appointment>>.broadcast();
  final _notesStream = StreamController<List<Note>>.broadcast();
  final _prescriptionStream = StreamController<List<Prescription>>.broadcast();

  MockRepository() {
    _emitAppointments();
  }

  void _emitAppointments() => _appointmentStream.add(List<Appointment>.from(_appointments));
  void _emitNotes(String appointmentId) => _notesStream.add(_notes.where((n) => n.appointmentId == appointmentId).toList());
  void _emitPrescriptions() => _prescriptionStream.add(List<Prescription>.from(_prescriptions));

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
        return a.time.year == day.year && a.time.month == day.month && a.time.day == day.day;
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
  Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx == -1) return Future.value(false);
    _appointments[idx] = Appointment(id: _appointments[idx].id, patientId: _appointments[idx].patientId, time: _appointments[idx].time, status: status);
    _emitAppointments();
    return Future.value(true);
  }

  @override
  Stream<List<Note>> fetchNotesStream(String appointmentId) {
    Timer.run(() => _emitNotes(appointmentId)); // Emit current notes immediately
    return _notesStream.stream.where((list) => list.isEmpty || list.first.appointmentId == appointmentId);
  }

  @override
  Future<Note> addNote(String appointmentId, String text) async {
    final note = Note(id: 'n${_notes.length + 1}', appointmentId: appointmentId, text: text, createdAt: DateTime.now());
    _notes.add(note);
    _emitNotes(appointmentId);
    return Future.value(note);
  }

  @override
  Future<bool> updateNote(String noteId, String newText) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      final oldNote = _notes[index];
      _notes[index] = Note(id: noteId, appointmentId: oldNote.appointmentId, text: newText, createdAt: oldNote.createdAt);
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
    return Future.value(_appointments.where((a) => a.patientId == patientId).toList());
  }

  @override
  Future<List<Note>> fetchAllNotesByPatient(String patientId) async {
    return _notes.where((n) => _appointments.any((a) => a.id == n.appointmentId && a.patientId == patientId)).toList();
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
      final isBooked = _appointments.any((a) => 
        a.time.year == start.year && 
        a.time.month == start.month && 
        a.time.day == start.day &&
        a.time.hour == start.hour &&
        a.time.minute == start.minute
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
}

// Initialize default repository to mock implementation.
void initMockRepository() {
  repository = MockRepository();
}
