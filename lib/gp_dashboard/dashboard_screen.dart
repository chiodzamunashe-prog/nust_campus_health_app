import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../psychiatrist_dashboard/models.dart';
import '../psychiatrist_dashboard/repository.dart';
import 'patient_summary_screen.dart';

enum GPDashboardViewMode { list, calendar }

class GPDashboardScreen extends StatefulWidget {
  const GPDashboardScreen({super.key});

  @override
  State<GPDashboardScreen> createState() => _GPDashboardScreenState();
}

class _GPDashboardScreenState extends State<GPDashboardScreen> {
  late Stream<List<Appointment>> _appointmentsStream;
  String _searchQuery = '';
  String _filterStatus = 'all';
  GPDashboardViewMode _viewMode = GPDashboardViewMode.list;

  // Calendar State
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _appointmentsStream = repository.fetchAppointments();
  }

  void _onViewToggle() {
    setState(() {
      _viewMode = _viewMode == GPDashboardViewMode.list
          ? GPDashboardViewMode.calendar
          : GPDashboardViewMode.list;

      // Update stream if switching to calendar
      if (_viewMode == GPDashboardViewMode.calendar && _selectedDay != null) {
        _appointmentsStream = repository.fetchAppointmentsForDay(_selectedDay!);
      } else {
        _appointmentsStream = repository.fetchAppointments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      appBar: AppBar(
        title: const Text('GP Dashboard'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Messages',
            onPressed: () => Navigator.pushNamed(context, '/chat_list'),
          ),
          IconButton(
            icon: Icon(
              _viewMode == GPDashboardViewMode.list
                  ? Icons.calendar_month
                  : Icons.list,
            ),
            onPressed: _onViewToggle,
            tooltip:
                'Switch to ${_viewMode == GPDashboardViewMode.list ? "Calendar" : "List"} View',
          ),
        ],
        bottom: _viewMode == GPDashboardViewMode.list
            ? _buildListFilters()
            : null,
      ),
      body: Column(
        children: [
          if (_viewMode == GPDashboardViewMode.calendar) _buildCalendar(),
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: _appointmentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var appointments = snapshot.data ?? [];

                // Secondary Filtering for Search and Status (if in list mode)
                if (_viewMode == GPDashboardViewMode.list &&
                    _filterStatus != 'all') {
                  appointments = appointments
                      .where((a) => a.status == _filterStatus)
                      .toList();
                }

                return Column(
                  children: [
                    if (_viewMode == GPDashboardViewMode.list)
                      _buildStatsBanner(snapshot.data ?? []),
                    if (_viewMode == GPDashboardViewMode.list)
                      _buildQuickActions(),
                    Expanded(
                      child: appointments.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'No appointments found for this selection.',
                                ),
                              ),
                            )
                          : _buildAppointmentList(appointments),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBanner(List<Appointment> all) {
    final today = DateTime.now();
    final todayCount = all
        .where(
          (a) =>
              a.time.year == today.year &&
              a.time.month == today.month &&
              a.time.day == today.day,
        )
        .length;
    final pending = all.where((a) => a.status == 'pending').length;
    final completed = all.where((a) => a.status == 'completed').length;

    final upcoming = all.where((a) => a.time.isAfter(DateTime.now())).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFFFFC107)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat('Today', todayCount.toString(), Icons.today),
          _buildStatDivider(),
          _buildStat('Upcoming', upcoming.toString(), Icons.schedule),
          _buildStatDivider(),
          _buildStat('Pending', pending.toString(), Icons.pending_actions),
          _buildStatDivider(),
          _buildStat(
            'Completed',
            completed.toString(),
            Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: Colors.white24);
  }

  PreferredSizeWidget _buildListFilters() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(180),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search patients, appointment IDs or status...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['all', 'pending', 'confirmed', 'completed', 'declined']
                  .map((status) {
                    final isSelected = _filterStatus == status;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1565C0),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (val) =>
                            setState(() => _filterStatus = status),
                        selectedColor: const Color(0xFF1565C0),
                        checkmarkColor: Colors.white,
                        backgroundColor: isSelected
                            ? const Color(0xFF1565C0)
                            : const Color(0xFFFFF8E1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : const Color(0xFFFFD54F),
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickActionButton(
                  label: 'New Appointment',
                  icon: Icons.add_circle_outline,
                  onPressed: _showNewAppointmentDialog,
                  color: const Color(0xFF1565C0),
                ),
                _buildQuickActionButton(
                  label: 'Follow-ups',
                  icon: Icons.follow_the_signs,
                  onPressed: _showFollowUpDialog,
                  color: const Color(0xFFFFC107),
                ),
                _buildQuickActionButton(
                  label: 'Patient Notes',
                  icon: Icons.note_alt,
                  onPressed: _showPatientNotes,
                  color: const Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildQuickActionButton(
            label: 'New Appointment',
            icon: Icons.add_circle_outline,
            onPressed: _showNewAppointmentDialog,
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(width: 8),
          _buildQuickActionButton(
            label: 'Follow-ups',
            icon: Icons.follow_the_signs,
            onPressed: _showFollowUpDialog,
            color: const Color(0xFFFFC107),
          ),
          const SizedBox(width: 8),
          _buildQuickActionButton(
            label: 'Patient Notes',
            icon: Icons.note_alt,
            onPressed: _showPatientNotes,
            color: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  void _showNewAppointmentDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Appointment'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Patient name or ID',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Appointment request created for ${titleController.text.isEmpty ? 'a patient' : titleController.text}',
                  ),
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showFollowUpDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Follow-up tasks'),
        content: const Text(
          'Review follow-up appointments, medication checks, and patient notes for today.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPatientNotes() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Patient Notes'),
        content: const Text(
          'Open patient records and consultation notes for faster review.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, Appointment appt) {
    DateTime selectedDate = appt.time.toLocal();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reschedule Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current time: ${_formatAppointmentTime(appt.time)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: dialogContext,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (picked != null) {
                  selectedDate = picked;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
              ),
              child: const Text('Pick new date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Appointment rescheduled to ${_formatAppointmentTime(selectedDate)}',
                  ),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: TableCalendar(
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _appointmentsStream = repository.fetchAppointmentsForDay(
              selectedDay,
            );
          });
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Color(0xFFFFC107),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Color(0xFF1565C0),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Color(0xFFFFC107),
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return FutureBuilder<Patient?>(
          future: repository.getPatientById(appt.patientId),
          builder: (c, psnap) {
            final patient = psnap.data;
            final patientName = patient?.name ?? 'Unknown';
            final appointmentTime = _formatAppointmentTime(appt.time);
            final currentContext = c;
            final timeLabel = appt.time.isAfter(DateTime.now())
                ? '${appt.time.difference(DateTime.now()).inMinutes} min away'
                : 'In progress';

            if (_viewMode == GPDashboardViewMode.list &&
                _searchQuery.isNotEmpty &&
                !patientName.toLowerCase().contains(_searchQuery)) {
              return const SizedBox.shrink();
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 1.8,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  if (patient != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GPPatientSummaryScreen(
                          patient: patient,
                          appointmentId: appt.id,
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF1565C0),
                            child: Text(
                              patientName.isNotEmpty
                                  ? patientName[0].toUpperCase()
                                  : 'G',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patientName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Appointment • $appointmentTime',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${appt.id}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildInfoTag('Age: ${patient?.age ?? '—'}'),
                          _buildInfoTag(
                            'Student ID: ${patient?.studentId ?? '—'}',
                          ),
                          _buildInfoTag('Status: ${appt.status}'),
                          _buildInfoTag(timeLabel),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: patient != null
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              GPPatientSummaryScreen(
                                                patient: patient,
                                                appointmentId: appt.id,
                                              ),
                                        ),
                                      );
                                    }
                                  : null,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                foregroundColor: const Color(0xFF1565C0),
                                side: const BorderSide(
                                  color: Color(0xFF1565C0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Patient Summary'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _showRescheduleDialog(currentContext, appt),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                foregroundColor: const Color(0xFFFFC107),
                                side: const BorderSide(
                                  color: Color(0xFFFFC107),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Reschedule'),
                            ),
                          ),
                        ],
                      ),
                      if ((patient?.summary ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          patient!.summary,
                          style: TextStyle(
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (appt.status == 'pending') ...[
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  final messenger = ScaffoldMessenger.of(
                                    currentContext,
                                  );
                                  repository
                                      .updateAppointmentStatus(
                                        appt.id,
                                        'confirmed',
                                      )
                                      .then((ok) {
                                        if (ok && mounted) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Appointment confirmed',
                                              ),
                                            ),
                                          );
                                        }
                                      });
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF1565C0),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Confirm'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  final messenger = ScaffoldMessenger.of(
                                    currentContext,
                                  );
                                  repository
                                      .updateAppointmentStatus(
                                        appt.id,
                                        'declined',
                                      )
                                      .then((ok) {
                                        if (ok && mounted) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Appointment declined',
                                              ),
                                            ),
                                          );
                                        }
                                      });
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFF3E0),
                                  foregroundColor: const Color(0xFFFFA000),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Decline'),
                              ),
                            ),
                          ] else if (appt.status == 'confirmed') ...[
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  final messenger = ScaffoldMessenger.of(
                                    currentContext,
                                  );
                                  repository
                                      .updateAppointmentStatus(
                                        appt.id,
                                        'completed',
                                      )
                                      .then((ok) {
                                        if (ok && mounted) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Appointment completed',
                                              ),
                                            ),
                                          );
                                        }
                                      });
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC107),
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Mark Completed'),
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1565C0),
                                  side: const BorderSide(
                                    color: Color(0xFF1565C0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Reviewed'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1565C0),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatAppointmentTime(DateTime time) {
    final local = time.toLocal();
    final hours = local.hour.toString().padLeft(2, '0');
    final minutes = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} $hours:$minutes';
  }
}
