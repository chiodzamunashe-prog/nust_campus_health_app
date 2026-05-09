import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff_model.dart';
import 'admin_repository.dart';

class FirestoreAdminRepository implements AdminRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<List<Staff>> fetchStaff() {
    return _db.collection('users')
        .where('role', whereIn: ['psychiatrist', 'gp', 'lab_tech', 'pharmacist', 'admin'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Staff(
          id: doc.id,
          name: data['displayName'] ?? 'Unknown',
          role: data['role'] ?? 'Staff',
          email: data['email'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
        );
      }).toList();
    });
  }

  @override
  Future<void> addStaff(Staff staff) async {
    // Note: Staff are usually added via Registration, but this allows manual admin adds
    await _db.collection('users').doc(staff.id.isEmpty ? null : staff.id).set({
      'displayName': staff.name,
      'role': staff.role,
      'email': staff.email,
      'phoneNumber': staff.phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateStaff(Staff staff) async {
    await _db.collection('users').doc(staff.id).update({
      'displayName': staff.name,
      'role': staff.role,
      'email': staff.email,
      'phoneNumber': staff.phoneNumber,
    });
  }

  @override
  Future<void> deleteStaff(String id) async {
    await _db.collection('users').doc(id).delete();
  }

  @override
  Future<Map<String, dynamic>> fetchAnalytics() async {
    final appts = await _db.collection('appointments').get();
    final users = await _db.collection('users').get();
    
    return {
      'totalAppointments': appts.size,
      'activeStaff': users.docs.where((d) => d['role'] != 'student').length,
      'registeredStudents': users.docs.where((d) => d['role'] == 'student').length,
      'pendingRequests': appts.docs.where((d) => d['status'] == 'pending').length,
    };
  }
}
