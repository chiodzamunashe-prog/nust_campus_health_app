class Patient {
  final String id;
  final String name;
  final int age;
  final String studentId;
  final String summary;

  Patient({required this.id, required this.name, required this.age, required this.studentId, this.summary = ''});
}

class Appointment {
  final String id;
  final String patientId;
  final DateTime time;
  final String status; // e.g., pending, confirmed, completed

  Appointment({required this.id, required this.patientId, required this.time, this.status = 'pending'});
}

class Note {
  final String id;
  final String appointmentId;
  final String text;
  final DateTime createdAt;

  Note({required this.id, required this.appointmentId, required this.text, required this.createdAt});
}
