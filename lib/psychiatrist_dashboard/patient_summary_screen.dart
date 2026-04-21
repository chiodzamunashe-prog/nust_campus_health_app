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

  @override
  void initState() {
    super.initState();
    _notesStream = repository.fetchNotesStream(widget.appointmentId);
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
            Text(
              'Student ID: ${widget.patient.studentId}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Age: ${widget.patient.age}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Text('Summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(widget.patient.summary),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(hintText: 'Add note...'),
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
            const SizedBox(height: 12),
            const Text(
              'Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Note>>(
                stream: _notesStream,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  final notes = snap.data ?? [];
                  if (notes.isEmpty) return const Text('No notes yet');
                  return ListView.separated(
                    itemCount: notes.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
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
            ),
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
