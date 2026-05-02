import '../models/staff_model.dart';

abstract class AdminRepository {
  Stream<List<Staff>> fetchStaff();
  Future<void> addStaff(Staff staff);
  Future<void> updateStaff(Staff staff);
  Future<void> deleteStaff(String id);
  Future<Map<String, dynamic>> fetchAnalytics();
}

class MockAdminRepository implements AdminRepository {
  final List<Staff> _mockStaff = [
    Staff(
      id: '1',
      name: 'Dr. Jane Smith',
      role: 'Psychiatrist',
      email: 'jane.smith@nust.ac.zw',
      phoneNumber: '+263771234567',
    ),
    Staff(
      id: '2',
      name: 'Dr. Zamazane Chiodza',
      role: 'General Practitioner',
      email: 'john.doe@nust.ac.zw',
      phoneNumber: '+263772222222',
    ),
  ];

  @override
  Stream<List<Staff>> fetchStaff() {
    return Stream.value(_mockStaff);
  }

  @override
  Future<void> addStaff(Staff staff) async {
    _mockStaff.add(staff);
  }

  @override
  Future<void> updateStaff(Staff staff) async {
    final index = _mockStaff.indexWhere((s) => s.id == staff.id);
    if (index != -1) {
      _mockStaff[index] = staff;
    }
  }

  @override
  Future<void> deleteStaff(String id) async {
    _mockStaff.removeWhere((s) => s.id == id);
  }

  @override
  Future<Map<String, dynamic>> fetchAnalytics() async {
    return {
      'totalAppointments': 124,
      'activeStaff': _mockStaff.length,
      'registeredStudents': 1540,
      'pendingRequests': 12,
    };
  }
}

late AdminRepository adminRepository;

void initAdminMockRepository() {
  adminRepository = MockAdminRepository();
}
