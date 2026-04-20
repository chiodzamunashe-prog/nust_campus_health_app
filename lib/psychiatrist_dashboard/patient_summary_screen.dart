import 'package:flutter/material.dart';
import 'models.dart';
import 'mock_service.dart';


class PatientSummaryScreen extends StatefulWidget {
  final Patient patient;
  final String appointmentId;

  const PatientSummaryScreen({super.key, required this.patient, required this.appointmentId});

  @override
  State<PatientSummaryScreen> createState() => _PatientSummaryScreenState();
}

class _PatientSummaryScreenState extends State<PatientSummaryScreen> {
  final TextEditingController _noteCtrl = TextEditingController();
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = MockService.fetchNotesByAppointment(widget.appointmentId);
  }

  Future<void> _refreshNotes() async {
    setState(() => _notesFuture = MockService.fetchNotesByAppointment(widget.appointmentId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.patient.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student ID: ${widget.patient.studentId}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Age: ${widget.patient.age}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text('Summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(widget.patient.summary),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: TextField(controller: _noteCtrl, decoration: const InputDecoration(hintText: 'Add note...')),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final text = _noteCtrl.text.trim();
                  if (text.isEmpty) return;
                  await MockService.addNote(widget.appointmentId, text);
                  _noteCtrl.clear();
                  await _refreshNotes();
                },
                child: const Text('Save'),
              )
            ]),
            const SizedBox(height: 12),
            const Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Note>>(
                future: _notesFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final notes = snap.data ?? [];
                  if (notes.isEmpty) return const Text('No notes yet');
                  return ListView.separated(
                    itemCount: notes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final n = notes[i];
                      return ListTile(
                        title: Text(n.text),
                        subtitle: Text(n.createdAt.toLocal().toString()),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }
}
