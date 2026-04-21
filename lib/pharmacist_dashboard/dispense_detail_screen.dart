import 'package:flutter/material.dart';
import '../models/prescription_model.dart';
import '../psychiatrist_dashboard/repository.dart';
import 'models.dart';

class DispenseDetailScreen extends StatefulWidget {
  final Prescription prescription;

  const DispenseDetailScreen({super.key, required this.prescription});

  @override
  State<DispenseDetailScreen> createState() => _DispenseDetailScreenState();
}

class _DispenseDetailScreenState extends State<DispenseDetailScreen> {
  bool _isProcessing = false;

  Future<void> _dispenseMedication() async {
    setState(() => _isProcessing = true);

    // 1. Update Prescription Status
    final success = await repository.updatePrescriptionStatus(widget.prescription.id, 'dispensed');

    if (success) {
      // 2. Try to update inventory if medication matches
      // This is a simple name-based match for the demo
      final inventory = await repository.fetchInventory().first;
      final med = inventory.where((m) => 
        widget.prescription.medication.toLowerCase().contains(m.name.toLowerCase()) ||
        m.name.toLowerCase().contains(widget.prescription.medication.toLowerCase())
      ).firstOrNull;

      if (med != null && med.stock > 0) {
        await repository.updateInventoryStock(med.id, med.stock - 1); // Simple decrement
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication dispensed successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to dispense medication'), backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prescription;
    final isPending = p.status == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispense Details'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientInfo(p),
            const SizedBox(height: 24),
            _buildPrescriptionInfo(p),
            const SizedBox(height: 32),
            if (isPending)
              ElevatedButton(
                onPressed: _isProcessing ? null : _showConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('DISPENSE MEDICATION', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text('MEDICATION ALREADY DISPENSED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfo(Prescription p) {
    return Card(
      elevation: 0,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.patientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('ID: ${p.patientId}', style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionInfo(Prescription p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prescription Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        _buildInfoRow(Icons.medication, 'Medication', p.medication),
        _buildInfoRow(Icons.scale, 'Dosage', p.dosage),
        _buildInfoRow(Icons.info_outline, 'Instructions', p.instructions),
        _buildInfoRow(Icons.person_pin, 'Prescribed By', p.doctorName),
        _buildInfoRow(Icons.calendar_today, 'Date', '${p.date.toLocal()}'.split(' ')[0]),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF003366), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Dispensing'),
        content: Text('Are you sure you want to mark ${widget.prescription.medication} as dispensed for ${widget.prescription.patientName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _dispenseMedication();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003366)),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
extension on List {
  get firstOrNull => isNotEmpty ? first : null;
}
