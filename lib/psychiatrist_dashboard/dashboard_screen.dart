import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models.dart';
import 'repository.dart';
import 'patient_summary_screen.dart';

enum DashboardViewMode { list, calendar }

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
  DashboardViewMode _viewMode = DashboardViewMode.list;

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
      _viewMode = _viewMode == DashboardViewMode.list
          ? DashboardViewMode.calendar
          : DashboardViewMode.list;

      // Update stream if switching to calendar
      if (_viewMode == DashboardViewMode.calendar && _selectedDay != null) {
        _appointmentsStream = repository.fetchAppointmentsForDay(_selectedDay!);
      } else {
        _appointmentsStream = repository.fetchAppointments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF003366);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Psychiatrist Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Messages',
            onPressed: () => Navigator.pushNamed(context, '/chat_list'),
          ),
          IconButton(
            icon: Icon(
              _viewMode == DashboardViewMode.list
                  ? Icons.calendar_month
                  : Icons.list,
            ),
            onPressed: _onViewToggle,
            tooltip:
                'Switch to ${_viewMode == DashboardViewMode.list ? "Calendar" : "List"} View',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_viewMode == DashboardViewMode.list) _buildStatsHeader(primaryColor),
          if (_viewMode == DashboardViewMode.calendar) _buildCalendar(),
          if (_viewMode == DashboardViewMode.list) _buildSearchAndFilter(primaryColor),
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

                // Filter logic
                if (_viewMode == DashboardViewMode.list) {
                  if (_filterStatus != 'all') {
                    appointments = appointments
                        .where((a) => a.status == _filterStatus)
                        .toList();
                  }
                }

                if (appointments.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildAppointmentList(appointments);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(Color primaryColor) {
    return StreamBuilder<List<Appointment>>(
      stream: repository.fetchAppointments(),
      builder: (context, snapshot) {
        final appointments = snapshot.data ?? [];
        final pending = appointments.where((a) => a.status == 'pending').length;
        final completed = appointments.where((a) => a.status == 'completed').length;
        final total = appointments.length;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Total', total.toString(), Icons.people_outline),
              _buildStatCard('Pending', pending.toString(), Icons.hourglass_empty, color: Colors.orangeAccent),
              _buildStatCard('Done', completed.toString(), Icons.check_circle_outline, color: Colors.greenAccent),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {Color color = Colors.white}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search patients...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'pending', 'confirmed', 'completed', 'declined'].map((status) {
                final isSelected = _filterStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status.toUpperCase()),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _filterStatus = status),
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No appointments found.',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    return ListView.builder(
      itemCount: appointments.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return FutureBuilder<Patient?>(
          future: repository.getPatientById(appt.patientId),
          builder: (c, psnap) {
            final patient = psnap.data;
            final patientName = patient?.name ?? 'Unknown';

            if (_viewMode == DashboardViewMode.list &&
                _searchQuery.isNotEmpty &&
                !patientName.toLowerCase().contains(_searchQuery)) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildAvatar(patientName),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      patientName,
                                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: ${patient?.studentId ?? 'N/A'} · ${patient?.age ?? '—'} yrs',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              _buildStatusIndicator(appt.status),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
                              const SizedBox(width: 6),
                              Text(
                                _formatAppointmentTime(appt.time),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          if (appt.reason.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              appt.reason,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _buildCardActions(appt, patient),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF003366), const Color(0xFF004488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCardActions(Appointment appt, Patient? patient) {
    return Row(
      children: [
        _buildCompactAction(Icons.medication_outlined, 'Prescribe', () {
          if (patient != null) Navigator.pushNamed(context, '/prescription_form', arguments: patient);
        }),
        const Spacer(),
        if (appt.status == 'pending') ...[
          _buildCompactAction(Icons.check, 'Accept', () => repository.updateAppointmentStatus(appt.id, 'confirmed'), isPrimary: true),
          const SizedBox(width: 8),
          _buildCompactAction(Icons.close, 'Decline', () => repository.updateAppointmentStatus(appt.id, 'declined'), isError: true),
        ] else if (appt.status == 'confirmed') ...[
          _buildCompactAction(Icons.done_all, 'Complete', () => repository.updateAppointmentStatus(appt.id, 'completed'), isPrimary: true),
        ],
      ],
    );
  }

  Widget _buildCompactAction(IconData icon, String label, VoidCallback onTap, {bool isPrimary = false, bool isError = false}) {
    final color = isPrimary ? const Color(0xFF003366) : (isError ? Colors.red : Colors.grey[700]);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color!.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: isPrimary ? color.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!),
      ),
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
            _appointmentsStream = repository.fetchAppointmentsForDay(selectedDay);
          });
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(color: Color(0xFFFFB81C), shape: BoxShape.circle),
          todayDecoration: BoxDecoration(color: const Color(0xFF003366).withOpacity(0.3), shape: BoxShape.circle),
          markerDecoration: const BoxDecoration(color: Color(0xFF003366), shape: BoxShape.circle),
        ),
      ),
    );
  }

  String _formatAppointmentTime(DateTime time) {
    final localTime = time.toLocal();
    final hour = localTime.hour > 12 ? localTime.hour - 12 : (localTime.hour == 0 ? 12 : localTime.hour);
    final period = localTime.hour >= 12 ? 'PM' : 'AM';
    return '${localTime.day}/${localTime.month} · $hour:${localTime.minute.toString().padLeft(2, '0')} $period';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.green;
      case 'completed': return Colors.blue;
      case 'declined': return Colors.red;
      default: return Colors.grey;
    }
  }
}
