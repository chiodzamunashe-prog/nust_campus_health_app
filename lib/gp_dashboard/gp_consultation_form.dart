import 'package:flutter/material.dart';
import '../psychiatrist_dashboard/repository.dart';

class GPConsultationForm extends StatefulWidget {
  final String appointmentId;

  const GPConsultationForm({super.key, required this.appointmentId});

  @override
  State<GPConsultationForm> createState() => _GPConsultationFormState();
}

class _GPConsultationFormState extends State<GPConsultationForm> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsCtrl = TextEditingController();
  final _observationsCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _planCtrl = TextEditingController();

  bool _isSaving = false;

  void _saveConsultation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Format the note as structured markdown/text
    final noteText = '''
**Symptoms / Chief Complaint:**
${_symptomsCtrl.text.trim()}

**Clinical Observations:**
${_observationsCtrl.text.trim().isNotEmpty ? _observationsCtrl.text.trim() : 'None noted.'}

**Diagnosis:**
${_diagnosisCtrl.text.trim()}

**Treatment Plan:**
${_planCtrl.text.trim()}
    '''.trim();

    await repository.addNote(widget.appointmentId, noteText);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation saved successfully'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    _observationsCtrl.dispose();
    _diagnosisCtrl.dispose();
    _planCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Consultation Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _symptomsCtrl,
                label: 'Symptoms / Chief Complaint',
                icon: Icons.personal_injury,
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _observationsCtrl,
                label: 'Clinical Observations',
                icon: Icons.visibility,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _diagnosisCtrl,
                label: 'Diagnosis',
                icon: Icons.medical_information,
                maxLines: 1,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _planCtrl,
                label: 'Treatment Plan / Notes',
                icon: Icons.healing,
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveConsultation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Save Consultation', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
