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
      appBar: AppBar(
        title: const Text('GP Dashboard'),
        backgroundColor: const Color(0xFF004D40), // Dark Teal for GP
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Messages',
            onPressed: () => Navigator.pushNamed(context, '/chat_list'),
          ),
          IconButton(
            icon: Icon(_viewMode == GPDashboardViewMode.list ? Icons.calendar_month : Icons.list),
            onPressed: _onViewToggle,
            tooltip: 'Switch to ${_viewMode == GPDashboardViewMode.list ? "Calendar" : "List"} View',
          ),
        ],
        bottom: _viewMode == GPDashboardViewMode.list ? _buildListFilters() : null,
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
                if (_viewMode == GPDashboardViewMode.list && _filterStatus != 'all') {
                  appointments = appointments.where((a) => a.status == _filterStatus).toList();
                }

                return Column(
                  children: [
                    if (_viewMode == GPDashboardViewMode.list)
                      _buildStatsBanner(snapshot.data ?? []),
                    Expanded(
                      child: appointments.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text('No appointments found for this selection.'),
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
    final todayCount = all.where((a) =>
      a.time.year == today.year && a.time.month == today.month && a.time.day == today.day).length;
    final pending = all.where((a) => a.status == 'pending').length;
    final completed = all.where((a) => a.status == 'completed').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF00796B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat('Today', todayCount.toString(), Icons.today),
          _buildStatDivider(),
          _buildStat('Pending', pending.toString(), Icons.pending_actions),
          _buildStatDivider(),
          _buildStat('Completed', completed.toString(), Icons.check_circle_outline),
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
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: Colors.white24);
  }

  PreferredSizeWidget _buildListFilters() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['all', 'pending', 'confirmed', 'completed', 'declined'].map((status) {
                final isSelected = _filterStatus == status;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _filterStatus = status),
                    selectedColor: const Color(0xFF004D40),
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
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
            _appointmentsStream = repository.fetchAppointmentsForDay(selectedDay);
          });
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(color: Color(0xFF00796B), shape: BoxShape.circle),
          todayDecoration: BoxDecoration(color: Color(0xFF004D40), shape: BoxShape.circle),
          markerDecoration: BoxDecoration(color: Color(0xFF004D40), shape: BoxShape.circle),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(color: Color(0xFF004D40), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    return ListView.separated(
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return FutureBuilder<Patient?>(
          future: repository.getPatientById(appt.patientId),
          builder: (c, psnap) {
            final patient = psnap.data;
            final patientName = patient?.name ?? 'Unknown';

            if (_viewMode == GPDashboardViewMode.list &&
                _searchQuery.isNotEmpty &&
                !patientName.toLowerCase().contains(_searchQuery)) {
              return const SizedBox.shrink();
            }

            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF004D40),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${appt.time.toLocal()}'.split('.')[0]),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(appt.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(appt.status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      if (appt.status == 'pending') ...[
                        _buildActionButton('Accept', () => repository.updateAppointmentStatus(appt.id, 'confirmed')),
                        _buildActionButton('Decline', () => repository.updateAppointmentStatus(appt.id, 'declined'), isError: true),
                      ] else if (appt.status == 'confirmed') ...[
                        _buildActionButton('Mark Completed', () => repository.updateAppointmentStatus(appt.id, 'completed'), isSuccess: true),
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
                      builder: (_) => GPPatientSummaryScreen(patient: patient, appointmentId: appt.id),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, {bool isError = false, bool isSuccess = false}) {
    Color color = Colors.blue;
    if (isError) color = Colors.redAccent;
    if (isSuccess) color = Colors.green;
    return TextButton(
      onPressed: onPressed, 
      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange[100]!;
      case 'confirmed': return Colors.green[100]!;
      case 'completed': return Colors.blue[100]!;
      case 'declined': return Colors.red[100]!;
      default: return Colors.grey[200]!;
    }
  }
}
