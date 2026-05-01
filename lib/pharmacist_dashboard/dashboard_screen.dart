import 'package:flutter/material.dart';
import '../models/prescription_model.dart';
import '../psychiatrist_dashboard/repository.dart';
import 'models.dart';
import 'dispense_detail_screen.dart';

class PharmacistDashboardScreen extends StatefulWidget {
  const PharmacistDashboardScreen({super.key});

  @override
  State<PharmacistDashboardScreen> createState() =>
      _PharmacistDashboardScreenState();
}

class _PharmacistDashboardScreenState extends State<PharmacistDashboardScreen> {
  String _searchQuery = '';

  List<Prescription> get _samplePrescriptions => [
    Prescription(
      id: 'sample-1',
      patientId: 'patient-001',
      patientName: 'Amina Chirwa',
      doctorName: 'Dr. Tendai Mwangi',
      medication: 'Amoxicillin 500mg',
      dosage: '1 tablet, 3x/day',
      instructions: 'Take after meals for 7 days.',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'pending',
    ),
    Prescription(
      id: 'sample-2',
      patientId: 'patient-002',
      patientName: 'Brian K.',
      doctorName: 'Dr. Samuel Ncube',
      medication: 'Metformin 850mg',
      dosage: '1 tablet, 2x/day',
      instructions: 'Take with breakfast and dinner.',
      date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      status: 'dispensed',
    ),
    Prescription(
      id: 'sample-3',
      patientId: 'patient-003',
      patientName: 'Chauke N.',
      doctorName: 'Dr. Lindiwe Moyo',
      medication: 'Cough Syrup 100ml',
      dosage: '10ml, 3x/day',
      instructions: 'Shake well before use.',
      date: DateTime.now().subtract(const Duration(hours: 8)),
      status: 'pending',
    ),
  ];

  List<Medication> get _sampleInventory => [
    Medication(
      id: 'med-1',
      name: 'Paracetamol',
      category: 'Pain Relief',
      stock: 42,
      unit: 'tablets',
    ),
    Medication(
      id: 'med-2',
      name: 'Ibuprofen',
      category: 'Anti-inflammatory',
      stock: 72,
      unit: 'tablets',
    ),
    Medication(
      id: 'med-3',
      name: 'Saline IV',
      category: 'Fluids',
      stock: 18,
      unit: 'bags',
    ),
    Medication(
      id: 'med-4',
      name: 'Vitamin C',
      category: 'Supplements',
      stock: 118,
      unit: 'tablets',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FF),
        appBar: AppBar(
          title: const Text('Pharmacist Dashboard'),
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFFFFC107)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: TabBar(
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Color.fromRGBO(255, 255, 255, 0.25),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Prescriptions', icon: Icon(Icons.receipt_long)),
              Tab(text: 'Inventory', icon: Icon(Icons.inventory_2)),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildPrescriptionsTab(), _buildInventoryTab()],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search prescriptions...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue.shade100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue.shade100),
          ),
        ),
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, String note, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              note,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return Column(
      children: [
        _buildSearchField(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildInfoCard(
                'Pending',
                '8',
                'Needs dispensing',
                const Color(0xFF1565C0),
              ),
              const SizedBox(width: 12),
              _buildInfoCard(
                'Ready',
                '14',
                'Ready for pickup',
                const Color(0xFFFFC107),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<List<Prescription>>(
            stream: repository.fetchAllPrescriptions(),
            builder: (context, snapshot) {
              final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
              final prescriptions = hasData
                  ? snapshot.data!
                  : _samplePrescriptions;
              final filtered = _searchQuery.isNotEmpty
                  ? prescriptions
                        .where(
                          (p) =>
                              p.patientName.toLowerCase().contains(
                                _searchQuery,
                              ) ||
                              p.medication.toLowerCase().contains(_searchQuery),
                        )
                        .toList()
                  : prescriptions;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (filtered.isEmpty) {
                return const Center(child: Text('No prescriptions found.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: filtered.length,
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  final isPending = p.status == 'pending';
                  final isSample = !hasData;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        p.patientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            '${p.medication} • ${p.dosage}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Doctor: ${p.doctorName}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p.instructions,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isPending
                                      ? const Color(0xFFFFF8E1)
                                      : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  p.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isPending
                                        ? const Color(0xFFF57C00)
                                        : const Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _formatDate(p.date),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.blue.shade700,
                      ),
                      onTap: isSample
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DispenseDetailScreen(prescription: p),
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

  Widget _buildInventoryTab() {
    return StreamBuilder<List<Medication>>(
      stream: repository.fetchInventory(),
      builder: (context, snapshot) {
        final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
        final inventory = hasData ? snapshot.data! : _sampleInventory;
        final lowStockCount = inventory.where((m) => m.stock < 60).length;
        final categories = inventory.map((m) => m.category).toSet();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                children: [
                  _buildInfoCard(
                    'Stock Items',
                    inventory.length.toString(),
                    'Tracked inventory',
                    const Color(0xFF1565C0),
                  ),
                  const SizedBox(width: 12),
                  _buildInfoCard(
                    'Low Stock',
                    lowStockCount.toString(),
                    'Order soon',
                    const Color(0xFFFFC107),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: categories
                    .take(3)
                    .map(
                      (category) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: inventory.length,
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final med = inventory[index];
                  final lowStock = med.stock < 60;
                  final stockLevel = med.stock.clamp(0, 150);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: lowStock
                                  ? const Color(0xFFFFF3E0)
                                  : const Color(0xFFE3F2FD),
                              child: Icon(
                                Icons.medication,
                                color: lowStock
                                    ? const Color(0xFFEF6C00)
                                    : const Color(0xFF1565C0),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    med.category,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${med.stock} ${med.unit}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lowStock
                                    ? const Color(0xFFEF6C00)
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: (stockLevel / 150).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: const Color(0xFFECEFF1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              lowStock
                                  ? const Color(0xFFEF6C00)
                                  : const Color(0xFF1565C0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lowStock
                                  ? 'Reorder recommended'
                                  : 'Stock healthy',
                              style: TextStyle(
                                color: lowStock
                                    ? const Color(0xFFEF6C00)
                                    : Colors.green.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showUpdateStockDialog(med),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: const Color(0xFFE3F2FD),
                              ),
                              child: const Text(
                                'Adjust stock',
                                style: TextStyle(color: Color(0xFF1565C0)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showUpdateStockDialog(Medication med) {
    final controller = TextEditingController(text: med.stock.toString());
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Update Stock: ${med.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'New Stock Level',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(controller.text);
              if (newStock != null) {
                await repository.updateInventoryStock(med.id, newStock);
                if (!mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
