import 'package:flutter/material.dart';
import '../models/prescription_model.dart';
import '../psychiatrist_dashboard/models.dart';
import '../psychiatrist_dashboard/repository.dart';

class PrescriptionFormScreen extends StatefulWidget {
  final Patient patient;

  const PrescriptionFormScreen({super.key, required this.patient});

  @override
  State<PrescriptionFormScreen> createState() => _PrescriptionFormScreenState();
}

class _PrescriptionFormScreenState extends State<PrescriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final prescription = Prescription(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: widget.patient.id,
        patientName: widget.patient.name,
        doctorName: 'Dr. Smith', // Mock current user name
        medication: _medicationCtrl.text,
        dosage: _dosageCtrl.text,
        instructions: _instructionsCtrl.text,
        date: DateTime.now(),
      );

      final success = await repository.addPrescription(prescription);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription issued successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Prescription for ${widget.patient.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _medicationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (v) => v!.isEmpty ? 'Please enter medication name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g. 50mg)',
                  prefixIcon: Icon(Icons.straighten),
                ),
                validator: (v) => v!.isEmpty ? 'Please enter dosage' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Instructions (e.g. Once daily after meal)',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Please enter instructions' : null,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Issue Prescription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
