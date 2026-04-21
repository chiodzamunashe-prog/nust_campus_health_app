import 'models.dart';
import '../models/prescription_model.dart';
import '../pharmacist_dashboard/models.dart';
import '../lab_module/models.dart';

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
  Future<bool> updatePrescriptionStatus(String prescriptionId, String status);
  Stream<List<Prescription>> fetchAllPrescriptions();

  // Vitals Methods
  Future<bool> addVitals(Vitals vitals);
  Stream<List<Vitals>> fetchVitals(String patientId);

  // Inventory Methods
  Stream<List<Medication>> fetchInventory();
  Future<bool> updateInventoryStock(String medicationId, int newStock);

  // Lab Methods
  Future<bool> addLabRequest(LabRequest request);
  Stream<List<LabRequest>> fetchLabRequests();
  Future<bool> updateLabResult(String id, String result);
  Stream<List<LabRequest>> fetchLabRequestsForPatient(String patientId);

  // Admin Methods
  Stream<Map<String, dynamic>> fetchAdminStats();
}

// Default repository instance. Replace with FirestoreRepository when ready.
late DashboardRepository repository;
