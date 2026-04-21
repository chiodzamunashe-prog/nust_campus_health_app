import 'models.dart';

abstract class DashboardRepository {
  Stream<List<Appointment>> fetchAppointments();
  Future<Patient?> getPatientById(String id);
  Future<bool> updateAppointmentStatus(String appointmentId, String status);
  Stream<List<Note>> fetchNotesStream(String appointmentId);
  Future<Note> addNote(String appointmentId, String text);
}

// Default repository instance. Replace with FirestoreRepository when ready.
late DashboardRepository repository;
