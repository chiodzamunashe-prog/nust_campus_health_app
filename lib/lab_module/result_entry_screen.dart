
  void _saveResult() async {
    if (_resultController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter test results'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final success = await repository.updateLabResult(
      widget.request.id,
      _resultController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Result uploaded successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload result'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final isCompleted = r.status == 'completed';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Enter Test Result',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header Card
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: Color(0xFF1565C0),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            r.patientName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.badge, 'Patient ID', r.patientId),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.science, 'Test Type', r.testType),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.person_outline, 'Doctor', r.doctorName),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.access_time,
                      'Ordered',
                      _formatDateTime(r.orderedAt),
                    ),
                    if (r.completedAt != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.check_circle,
                        'Completed',
                        _formatDateTime(r.completedAt!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFF1F8E9)
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                      : const Color(0xFFFFC107).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.pending,
                    color: isCompleted
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF6F00),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCompleted ? 'Test Completed' : 'Test Pending',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFEF6C00),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Results Section
            const Text(
              'Laboratory Findings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _resultController,
                  maxLines: 12,
                  enabled: !isCompleted,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  decoration: InputDecoration(
                    hintText:
                        'Enter findings, measurements, or observations...\n\nExample:\n- Hemoglobin: 14.2 g/dL (Normal: 12-16 g/dL)\n- White Blood Cells: 7.8 × 10³/µL (Normal: 4-11 × 10³/µL)\n- Platelets: 285 × 10³/µL (Normal: 150-450 × 10³/µL)\n\nConclusion: All parameters within normal range.',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            if (!isCompleted) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF1565C0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveResult,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'UPLOAD RESULT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 48,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Test Result Already Submitted',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This test has been completed and the results have been recorded.',
                      style: TextStyle(color: Color(0xFF424242), fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF424242),
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF616161), fontSize: 16),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
