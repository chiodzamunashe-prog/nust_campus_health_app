import 'package:flutter/material.dart';
import '../psychiatrist_dashboard/models.dart';
import '../psychiatrist_dashboard/repository.dart';
import '../lab_module/models.dart';
import 'vitals_form.dart';
import 'gp_consultation_form.dart';
import '../auth/auth_service.dart';

class GPPatientSummaryScreen extends StatefulWidget {
  final Patient patient;
  final String appointmentId;

  const GPPatientSummaryScreen({super.key, required this.patient, required this.appointmentId});

  @override
  State<GPPatientSummaryScreen> createState() => _GPPatientSummaryScreenState();
}

class _GPPatientSummaryScreenState extends State<GPPatientSummaryScreen> {
  late Stream<List<Note>> _notesStream;
  late Stream<List<Vitals>> _vitalsStream;
  late Stream<List<LabRequest>> _labStream;
  late Future<List<Appointment>> _historyFuture;
  late Future<List<Note>> _allNotesFuture;

  @override
  void initState() {
    super.initState();
    _notesStream = repository.fetchNotesStream(widget.appointmentId);
    _vitalsStream = repository.fetchVitals(widget.patient.id);
    _labStream = repository.fetchLabRequestsForPatient(widget.patient.id);
    _historyFuture = repository.fetchPatientHistory(widget.patient.id);
    _allNotesFuture = repository.fetchAllNotesByPatient(widget.patient.id);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF004D40),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.medication),
              tooltip: 'Issue Prescription',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/prescription_form',
                  arguments: widget.patient,
                );
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Consultation', icon: Icon(Icons.note_alt)),
              Tab(text: 'Vitals', icon: Icon(Icons.monitor_heart)),
              Tab(text: 'Lab', icon: Icon(Icons.biotech)),
              Tab(text: 'History', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildConsultationTab(),
            _buildVitalsTab(),
            _buildLabTab(),
            _buildHistoryTab(),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () {
                final tabController = DefaultTabController.of(context);
                if (tabController.index == 3) {
                  return; // No FAB action for History
                } else if (tabController.index == 2) {
                  _showOrderLabDialog();
                } else if (tabController.index == 1) {
                  _showVitalsForm();
                } else {
                  _showNoteDialog();
                }
              },
              backgroundColor: const Color(0xFF004D40),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Entry', style: TextStyle(color: Colors.white)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConsultationTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.teal[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Patient Summary', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
              const SizedBox(height: 4),
              Text(widget.patient.summary.isEmpty ? 'No summary available.' : widget.patient.summary),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Note>>(
            stream: _notesStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final notes = snapshot.data!;
              if (notes.isEmpty) return const Center(child: Text('No notes for this session.'));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${note.createdAt.toLocal()}'.split('.')[0],
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                onPressed: () => repository.deleteNote(note.id),
                              ),
                            ],
                          ),
                          Text(note.text),
                        ],
                      ),
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

  Widget _buildVitalsTab() {
    return StreamBuilder<List<Vitals>>(
      stream: _vitalsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final vitalsList = snapshot.data!;
        if (vitalsList.isEmpty) return const Center(child: Text('No vitals recorded yet.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vitalsList.length,
          itemBuilder: (context, index) {
            final v = vitalsList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recorded on ${v.recordedAt.toLocal()}'.split('.')[0],
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
                        ),
                        const Icon(Icons.history, size: 16, color: Colors.grey),
                      ],
                    ),
                    const Divider(),
                    Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: [
                        _buildVitalItem(Icons.compress, 'BP', v.bloodPressure),
                        _buildVitalItem(Icons.thermostat, 'Temp', '${v.temperature}°C'),
                        _buildVitalItem(Icons.favorite, 'HR', '${v.heartRate} bpm'),
                        _buildVitalItem(Icons.monitor_weight, 'Weight', '${v.weight} kg'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVitalItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.teal),
        const SizedBox(width: 4),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value),
      ],
    );
  }

  void _showNoteDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => GPConsultationForm(appointmentId: widget.appointmentId),
    );
  }

  void _showVitalsForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => VitalsForm(patientId: widget.patient.id),
    );
  }

  Widget _buildLabTab() {
    return StreamBuilder<List<LabRequest>>(
      stream: _labStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final requests = snapshot.data!;
        if (requests.isEmpty) return const Center(child: Text('No lab tests ordered yet.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final r = requests[index];
            final isCompleted = r.status == 'completed';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: Icon(isCompleted ? Icons.check_circle : Icons.pending, color: isCompleted ? Colors.green : Colors.orange),
                title: Text(r.testType, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Ordered on: ${r.orderedAt.toLocal()}'.split('.')[0], style: const TextStyle(fontSize: 12)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Result:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                        const SizedBox(height: 4),
                        Text(isCompleted ? r.result : 'Awaiting results from laboratory...'),
                        if (isCompleted) ...[
                          const SizedBox(height: 8),
                          Text('Completed at: ${r.completedAt?.toLocal()}'.split('.')[0], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showOrderLabDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Laboratory Test'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g. Malaria Test, Full Blood Count',
            labelText: 'Test Type',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final request = LabRequest(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                patientId: widget.patient.id,
                patientName: widget.patient.name,
                doctorName: AuthService.instance.currentUser ?? 'Unknown',
                testType: controller.text.trim(),
                orderedAt: DateTime.now(),
              );
              await repository.addLabRequest(request);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40)),
            child: const Text('Order Test'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return FutureBuilder<List<Object>>(
      future: Future.wait([_historyFuture, _allNotesFuture]),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snap.data as List<dynamic>?;
        final historyAppts = results?[0] as List<Appointment>? ?? [];
        final allNotes = results?[1] as List<Note>? ?? [];

        final pastAppts = historyAppts.where((a) => a.id != widget.appointmentId).toList();

        if (pastAppts.isEmpty) {
          return const Center(child: Text('No past appointments found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pastAppts.length,
          itemBuilder: (context, index) {
            final appt = pastAppts[index];
            final apptNotes = allNotes.where((n) => n.appointmentId == appt.id).toList();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text('Session: ${appt.time.toLocal()}'.split('.')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Status: ${appt.status}'),
                leading: Icon(
                  appt.status == 'completed' ? Icons.check_circle : Icons.history,
                  color: appt.status == 'completed' ? Colors.green : Colors.grey,
                ),
                children: [
                  if (apptNotes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No notes for this session.'),
                    )
                  else
                    ...apptNotes.map((n) => ListTile(
                          title: Text(n.text),
                          subtitle: Text(n.createdAt.toLocal().toString().split('.')[0]),
                        )),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
