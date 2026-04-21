import 'package:flutter/material.dart';
import 'models.dart';
import 'repository.dart';

class PatientSummaryScreen extends StatefulWidget {
  final Patient patient;
  final String appointmentId;

  const PatientSummaryScreen({
    super.key,
    required this.patient,
    required this.appointmentId,
  });

  @override
  State<PatientSummaryScreen> createState() => _PatientSummaryScreenState();
}

class _PatientSummaryScreenState extends State<PatientSummaryScreen> {
  final TextEditingController _noteCtrl = TextEditingController();
  late Stream<List<Note>> _notesStream;
  late Future<List<Appointment>> _historyFuture;
  late Future<List<Note>> _allNotesFuture;

  @override
  void initState() {
    super.initState();
    _notesStream = repository.fetchNotesStream(widget.appointmentId);
    _historyFuture = repository.fetchPatientHistory(widget.patient.id);
    _allNotesFuture = repository.fetchAllNotesByPatient(widget.patient.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
            tooltip: 'Mark as Completed',
            onPressed: () async {
              final ok = await repository.updateAppointmentStatus(widget.appointmentId, 'completed');
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment marked as completed')));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientDetails(context),
              const Divider(height: 32),
              _buildCurrentSessionNotes(context),
              const Divider(height: 48, thickness: 2),
              _buildPatientHistory(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Student ID: ${widget.patient.studentId}', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        Text('Age: ${widget.patient.age}', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        Text('Summary', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(widget.patient.summary),
      ],
    );
  }

  Widget _buildCurrentSessionNotes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Current Session Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _noteCtrl,
                decoration: const InputDecoration(hintText: 'Add new note...'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final text = _noteCtrl.text.trim();
                if (text.isEmpty) return;
                await repository.addNote(widget.appointmentId, text);
                _noteCtrl.clear();
              },
              child: const Text('Save'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Note>>(
          stream: _notesStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
            final notes = snap.data ?? [];
            if (notes.isEmpty) return const Text('No notes for this session yet.');
            return Column(
              children: notes.map((n) => ListTile(
                title: Text(n.text),
                subtitle: Text(n.createdAt.toLocal().toString()),
                contentPadding: EdgeInsets.zero,
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPatientHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patient History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Object>>(
          future: Future.wait([_historyFuture, _allNotesFuture]),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            final results = snap.data as List<dynamic>?;
            final historyAppts = results?[0] as List<Appointment>? ?? [];
            final allNotes = results?[1] as List<Note>? ?? [];

            // Filter out the current appointment
            final pastAppts = historyAppts.where((a) => a.id != widget.appointmentId).toList();

            if (pastAppts.isEmpty) {
              return const Text('No past appointments found.');
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pastAppts.length,
              itemBuilder: (context, index) {
                final appt = pastAppts[index];
                final apptNotes = allNotes.where((n) => n.appointmentId == appt.id).toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text('Session: ${appt.time.toLocal()}'),
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
                              subtitle: Text(n.createdAt.toLocal().toString()),
                            )),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }
}
