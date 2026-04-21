import 'package:flutter/material.dart';
import '../models/prescription_model.dart';
import '../psychiatrist_dashboard/repository.dart';
import 'models.dart';
import 'dispense_detail_screen.dart';

class PharmacistDashboardScreen extends StatefulWidget {
  const PharmacistDashboardScreen({super.key});

  @override
  State<PharmacistDashboardScreen> createState() => _PharmacistDashboardScreenState();
}

class _PharmacistDashboardScreenState extends State<PharmacistDashboardScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pharmacist Dashboard'),
          backgroundColor: const Color(0xFF003366),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Prescriptions', icon: Icon(Icons.receipt_long)),
              Tab(text: 'Inventory', icon: Icon(Icons.inventory_2)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPrescriptionsTab(),
            _buildInventoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by Patient Name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Prescription>>(
            stream: repository.fetchAllPrescriptions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              var prescriptions = snapshot.data ?? [];
              
              // Filtering
              if (_searchQuery.isNotEmpty) {
                prescriptions = prescriptions.where((p) => p.patientName.toLowerCase().contains(_searchQuery)).toList();
              }

              if (prescriptions.isEmpty) {
                return const Center(child: Text('No prescriptions found.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: prescriptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = prescriptions[index];
                  final isPending = p.status == 'pending';
                  
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(p.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Medication: ${p.medication}'),
                          Text('Prescribed by: ${p.doctorName}'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPending ? Colors.orange[100] : Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold,
                                color: isPending ? Colors.orange[900] : Colors.green[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DispenseDetailScreen(prescription: p),
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
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final inventory = snapshot.data!;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: inventory.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final med = inventory[index];
            final lowStock = med.stock < 50;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: lowStock ? Colors.red[50] : Colors.blue[50],
                child: Icon(Icons.medication, color: lowStock ? Colors.red : Colors.blue),
              ),
              title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(med.category),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${med.stock} ${med.unit}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: lowStock ? Colors.red : Colors.black87,
                    ),
                  ),
                  if (lowStock)
                    const Text('Low Stock', style: TextStyle(color: Colors.red, fontSize: 10)),
                ],
              ),
              onTap: () => _showUpdateStockDialog(med),
            );
          },
        );
      },
    );
  }

  void _showUpdateStockDialog(Medication med) {
    final controller = TextEditingController(text: med.stock.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock: ${med.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New Stock Level', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(controller.text);
              if (newStock != null) {
                await repository.updateInventoryStock(med.id, newStock);
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
