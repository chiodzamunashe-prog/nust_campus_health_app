import 'dart:async';
import 'models.dart';
import 'repository.dart';

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

  final _appointmentStream = StreamController<List<Appointment>>.broadcast();
  final _notesStream = StreamController<List<Note>>.broadcast();

  MockRepository() {
    _emitAppointments();
  }

  void _emitAppointments() => _appointmentStream.add(List<Appointment>.from(_appointments));
  void _emitNotes(String appointmentId) => _notesStream.add(_notes.where((n) => n.appointmentId == appointmentId).toList());

  @override
  Stream<List<Appointment>> fetchAppointments() {
    Timer.run(() => _emitAppointments());
    return _appointmentStream.stream;
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
  Future<List<Appointment>> fetchPatientHistory(String patientId) async {
    // Return all appointments for this patient, but only those in the past or completed
    return Future.value(_appointments.where((a) => a.patientId == patientId).toList());
  }

  @override
  Future<List<Note>> fetchAllNotesByPatient(String patientId) async {
    final patientApptIds = _appointments.where((a) => a.patientId == patientId).map((a) => a.id).toSet();
    return Future.value(_notes.where((n) => patientApptIds.contains(n.appointmentId)).toList());
  }
}

// Initialize default repository to mock implementation.
void initMockRepository() {
  repository = MockRepository();
}
