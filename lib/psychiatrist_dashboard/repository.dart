import 'models.dart';

abstract class DashboardRepository {
  Future<List<Appointment>> fetchAppointments();
  Future<Patient?> getPatientById(String id);
  Future<bool> updateAppointmentStatus(String appointmentId, String status);
  Future<List<Note>> fetchNotesByAppointment(String appointmentId);
  Future<Note> addNote(String appointmentId, String text);
}

// Default repository instance. Replace with FirestoreRepository when ready.
late DashboardRepository repository;
