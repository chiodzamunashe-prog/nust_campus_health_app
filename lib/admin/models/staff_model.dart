class Staff {
  final String id;
  final String name;
  final String role; // e.g., Psychiatrist, GP, Nurse
  final String email;
  final String phoneNumber;
  final String department;
  final bool isActive;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.phoneNumber,
    this.department = 'Campus Health',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'phoneNumber': phoneNumber,
      'department': department,
      'isActive': isActive,
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map, String id) {
    return Staff(
      id: id,
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      department: map['department'] ?? 'Campus Health',
      isActive: map['isActive'] ?? true,
    );
  }
}
