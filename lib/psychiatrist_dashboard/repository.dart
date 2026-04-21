import 'models.dart';
import '../models/prescription_model.dart';

abstract class DashboardRepository {
  Stream<List<Appointment>> fetchAppointments();
  Stream<List<Appointment>> fetchAppointmentsForDay(DateTime day);
  Future<Patient?> getPatientById(String id);
  Future<bool> updateAppointmentStatus(String appointmentId, String status);
  Stream<List<Note>> fetchNotesStream(String appointmentId);
  Future<Note> addNote(String appointmentId, String text);
  Future<bool> updateNote(String noteId, String newText);
  Future<bool> deleteNote(String noteId);
  Future<List<Appointment>> fetchPatientHistory(String patientId);
  Future<List<Note>> fetchAllNotesByPatient(String patientId);

  // Student Booking Methods
  Future<bool> createAppointment(Appointment appointment);
  Stream<List<Appointment>> fetchAppointmentsForStudent(String patientId);
  Future<List<DateTime>> fetchAvailableSlots(DateTime day);

  // Prescription Methods
  Future<bool> addPrescription(Prescription prescription);
  Stream<List<Prescription>> fetchPrescriptionsForPatient(String patientId);
}

// Default repository instance. Replace with FirestoreRepository when ready.
late DashboardRepository repository;
