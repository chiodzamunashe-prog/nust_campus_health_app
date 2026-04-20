import 'models.dart';

class MockService {
  static final List<Patient> _patients = [
    Patient(id: 'p1', name: 'Alice Banda', age: 21, studentId: 'NUST001', summary: 'Anxiety, occasional insomnia.'),
    Patient(id: 'p2', name: 'Brian Chirwa', age: 23, studentId: 'NUST002', summary: 'Mood swings, past therapy.'),
  ];

  static final List<Appointment> _appointments = [
    Appointment(id: 'a1', patientId: 'p1', time: DateTime.now().add(const Duration(hours: 2)), status: 'pending'),
    Appointment(id: 'a2', patientId: 'p2', time: DateTime.now().add(const Duration(days: 1)), status: 'confirmed'),
  ];

  static final List<Note> _notes = [];

  static Future<List<Appointment>> fetchAppointments() async {
    return Future.value(List<Appointment>.from(_appointments));
  }

  static Future<Patient?> getPatientById(String id) async {
    try {
      return Future.value(_patients.firstWhere((p) => p.id == id));
    } catch (_) {
      return Future.value(null);
    }
  }

  // Update appointment status (e.g., accept, decline, confirmed, completed)
  static Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx == -1) return Future.value(false);
    _appointments[idx] = Appointment(id: _appointments[idx].id, patientId: _appointments[idx].patientId, time: _appointments[idx].time, status: status);
    return Future.value(true);
  }

  // Notes
  static Future<List<Note>> fetchNotesByAppointment(String appointmentId) async {
    return Future.value(_notes.where((n) => n.appointmentId == appointmentId).toList());
  }

  static Future<Note> addNote(String appointmentId, String text) async {
    final note = Note(id: 'n${_notes.length + 1}', appointmentId: appointmentId, text: text, createdAt: DateTime.now());
    _notes.add(note);
    return Future.value(note);
  }
}
