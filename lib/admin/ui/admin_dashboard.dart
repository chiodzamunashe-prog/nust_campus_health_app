import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../psychiatrist_dashboard/repository.dart';
import 'staff_management.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Clinic Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: repository.fetchAdminStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = snapshot.data ?? {};
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Operations Summary'),
                const SizedBox(height: 16),
                _buildStatsGrid(stats),
                const SizedBox(height: 32),
                _buildSectionHeader('Appointment Trends (7 Days)'),
                const SizedBox(height: 16),
                _buildTrendChart(stats['appointmentTrends'] ?? []),
                const SizedBox(height: 32),
                _buildSectionHeader('Clinic Performance'),
                const SizedBox(height: 16),
                _buildPerformanceRow(stats),
                const SizedBox(height: 32),
                _buildSectionHeader('Management'),
                const SizedBox(height: 16),
                _buildActionList(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMiniCard('Appointments', stats['totalAppointments']?.toString() ?? '0', Icons.calendar_today, Colors.blue),
        _buildMiniCard('Pending Labs', stats['pendingLabs']?.toString() ?? '0', Icons.science, Colors.purple),
        _buildMiniCard('Low Stock', stats['lowStockMeds']?.toString() ?? '0', Icons.warning_amber, Colors.orange),
        _buildMiniCard('New Patients', '12', Icons.person_add, Colors.green),
      ],
    );
  }

  Widget _buildMiniCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<dynamic> data) {
    final List<int> trends = List<int>.from(data.isEmpty ? [0,0,0,0,0,0,0] : data);
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(trends.length, (i) => FlSpot(i.toDouble(), trends[i].toDouble())),
              isCurved: true,
              color: const Color(0xFF003366),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF003366).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoBox('Most Common Case', stats['mostCommonReason'] ?? 'N/A', Icons.trending_up, Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoBox('Avg. Wait Time', '14 mins', Icons.timer, Colors.orange),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionList(BuildContext context) {
    return Column(
      children: [
        _buildActionTile(Icons.people, 'Staff Management', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffManagementScreen()))),
        _buildActionTile(Icons.inventory, 'Supply Inventory', () {}),
        _buildActionTile(Icons.assignment, 'System Logs', () {}),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF003366)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
