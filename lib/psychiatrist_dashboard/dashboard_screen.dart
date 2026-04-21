import 'package:flutter/material.dart';
import 'models.dart';
import 'repository.dart';
import 'patient_summary_screen.dart';

class PsychiatristDashboardScreen extends StatefulWidget {
  const PsychiatristDashboardScreen({super.key});

  @override
  State<PsychiatristDashboardScreen> createState() =>
      _PsychiatristDashboardScreenState();
}

class _PsychiatristDashboardScreenState
    extends State<PsychiatristDashboardScreen> {
  late Stream<List<Appointment>> _appointmentsStream;
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _appointmentsStream = repository.fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Psychiatrist Dashboard'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search patients...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.toLowerCase()),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children:
                      [
                        'all',
                        'pending',
                        'confirmed',
                        'completed',
                        'declined',
                      ].map((status) {
                        final isSelected = _filterStatus == status;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(
                              status[0].toUpperCase() + status.substring(1),
                            ),
                            selected: isSelected,
                            onSelected: (val) =>
                                setState(() => _filterStatus = status),
                            selectedColor: Colors.deepPurple[100],
                            checkmarkColor: Colors.deepPurple,
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: _appointmentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var appointments = snapshot.data ?? [];

          // Apply status filter
          if (_filterStatus != 'all') {
            appointments = appointments
                .where((a) => a.status == _filterStatus)
                .toList();
          }

          if (appointments.isEmpty)
            return const Center(child: Text('No appointments found'));

          return ListView.separated(
            itemCount: appointments.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final appt = appointments[index];
              return FutureBuilder<Patient?>(
                future: repository.getPatientById(appt.patientId),
                builder: (c, psnap) {
                  final patient = psnap.data;
                  final patientName = patient?.name ?? 'Unknown';

                  // Apply search filter (Client-side localized name search)
                  if (_searchQuery.isNotEmpty &&
                      !patientName.toLowerCase().contains(_searchQuery)) {
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(patientName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${appt.time.toLocal()}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(appt.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                appt.status,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (appt.status == 'pending') ...[
                              TextButton(
                                onPressed: () =>
                                    repository.updateAppointmentStatus(
                                      appt.id,
                                      'confirmed',
                                    ),
                                child: const Text('Accept'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    repository.updateAppointmentStatus(
                                      appt.id,
                                      'declined',
                                    ),
                                child: const Text(
                                  'Decline',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (patient != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientSummaryScreen(
                              patient: patient,
                              appointmentId: appt.id,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange[100]!;
      case 'confirmed':
        return Colors.green[100]!;
      case 'completed':
        return Colors.blue[100]!;
      case 'declined':
        return Colors.red[100]!;
      default:
        return Colors.grey[200]!;
    }
  }
}
