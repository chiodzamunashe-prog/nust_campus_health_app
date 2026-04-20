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

  static Future<List<Appointment>> fetchAppointments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _appointments;
  }

  static Future<Patient?> getPatientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _patients.firstWhere((p) => p.id == id, orElse: () => _patients.isNotEmpty ? _patients.first : null);
  }
}
