import 'package:flutter/material.dart';
import '../psychiatrist_dashboard/repository.dart';
import 'models.dart';

class LabResultEntryScreen extends StatefulWidget {
  final LabRequest request;

  const LabResultEntryScreen({super.key, required this.request});

  @override
  State<LabResultEntryScreen> createState() => _LabResultEntryScreenState();
}

class _LabResultEntryScreenState extends State<LabResultEntryScreen> {
  final _resultController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _resultController.text = widget.request.result;
  }

  void _saveResult() async {
    if (_resultController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    final success = await repository.updateLabResult(widget.request.id, _resultController.text.trim());
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result uploaded successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload result'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final isCompleted = r.status == 'completed';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Test Result'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientHeader(r),
            const SizedBox(height: 24),
            const Text('Test Requested:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(r.testType, style: const TextStyle(fontSize: 20, color: Color(0xFF6A1B9A))),
            const SizedBox(height: 8),
            Text('Doctor: ${r.doctorName}', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            const Text('Laboratory Findings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _resultController,
              maxLines: 8,
              enabled: !isCompleted,
              decoration: InputDecoration(
                hintText: 'Enter findings, measurements, or observations...',
                border: const OutlineInputBorder(),
                filled: isCompleted,
                fillColor: isCompleted ? Colors.grey[100] : Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            if (!isCompleted)
              ElevatedButton(
                onPressed: _isSaving ? null : _saveResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('UPLOAD FINAL RESULT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('TEST COMPLETED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Completed at: ${r.completedAt?.toLocal()}'.split('.')[0], style: const TextStyle(fontSize: 12, color: Colors.green)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(LabRequest r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Color(0xFF6A1B9A), child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.patientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Patient ID: ${r.patientId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
