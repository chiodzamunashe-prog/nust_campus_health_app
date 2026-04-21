import 'package:flutter/material.dart';
import '../psychiatrist_dashboard/repository.dart';
import 'models.dart';
import 'result_entry_screen.dart';

class LabDashboardScreen extends StatefulWidget {
  const LabDashboardScreen({super.key});

  @override
  State<LabDashboardScreen> createState() => _LabDashboardScreenState();
}

class _LabDashboardScreenState extends State<LabDashboardScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lab Technician Dashboard'),
          backgroundColor: const Color(0xFF6A1B9A), // Purple for Lab
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Pending Requests', icon: Icon(Icons.biotech)),
              Tab(text: 'Completed Tests', icon: Icon(Icons.assignment_turned_in)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestList(isPending: true),
            _buildRequestList(isPending: false),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList({required bool isPending}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by Patient Name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<LabRequest>>(
            stream: repository.fetchLabRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              var requests = snapshot.data ?? [];
              requests = requests.where((r) => isPending ? r.status == 'pending' : r.status == 'completed').toList();

              if (_searchQuery.isNotEmpty) {
                requests = requests.where((r) => r.patientName.toLowerCase().contains(_searchQuery)).toList();
              }

              if (requests.isEmpty) {
                return Center(child: Text('No ${isPending ? "pending" : "completed"} requests found.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = requests[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(r.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildInfoChip(Icons.science, 'Test: ${r.testType}', Colors.purple[50]!, Colors.purple[900]!),
                          const SizedBox(height: 4),
                          Text('Requested by: ${r.doctorName}', style: const TextStyle(fontSize: 12)),
                          Text('Ordered: ${r.orderedAt.toLocal()}'.split('.')[0], style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LabResultEntryScreen(request: r),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
