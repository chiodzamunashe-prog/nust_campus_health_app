import 'package:flutter/material.dart';
import '../models/staff_model.dart';
import '../repository/admin_repository.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Staff>>(
        stream: adminRepository.fetchStaff(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final staffList = snapshot.data ?? [];
          if (staffList.isEmpty) {
            return const Center(child: Text('No staff members found.'));
          }
          return ListView.builder(
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${staff.role} • ${staff.department}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showStaffDialog(context, staff: staff),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, staff),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStaffDialog(context),
        backgroundColor: const Color(0xFF003366),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showStaffDialog(BuildContext context, {Staff? staff}) {
    final nameController = TextEditingController(text: staff?.name);
    final roleController = TextEditingController(text: staff?.role);
    final emailController = TextEditingController(text: staff?.email);
    final phoneController = TextEditingController(text: staff?.phoneNumber);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(staff == null ? 'Add Staff Member' : 'Edit Staff Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              TextField(controller: roleController, decoration: const InputDecoration(labelText: 'Role (e.g. GP, Psychiatrist)')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newStaff = Staff(
                id: staff?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                role: roleController.text,
                email: emailController.text,
                phoneNumber: phoneController.text,
              );
              if (staff == null) {
                adminRepository.addStaff(newStaff);
              } else {
                adminRepository.updateStaff(newStaff);
              }
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Staff staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff?'),
        content: Text('Are you sure you want to remove ${staff.name} from the system?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              adminRepository.deleteStaff(staff.id);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
