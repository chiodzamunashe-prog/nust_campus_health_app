import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../psychiatrist_dashboard/models.dart';
import '../psychiatrist_dashboard/repository.dart';
import '../auth/auth_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _reasonCtrl = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _selectedSlot;
  String _selectedType = 'psychiatrist';
  List<DateTime> _availableSlots = [];
  bool _isLoadingSlots = false;
  
  List<Map<String, String>> _patients = [];
  String? _selectedPatientId;
  String? _selectedPatientName;
  bool _isLoadingPatients = false;

  @override
  void initState() {
    super.initState();
    _fetchSlots(DateTime.now());
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    final role = AuthService.instance.userRole.value;
    if (role == UserRole.student) return;

    setState(() => _isLoadingPatients = true);
    
    List<String> rolesToFetch = [];
    if (role == UserRole.psychiatrist) {
      rolesToFetch = ['student'];
    } else {
      // Admin or GP can book for everyone
      rolesToFetch = ['student', 'psychiatrist', 'gp', 'lab_tech', 'pharmacist', 'admin'];
    }

    final users = await repository.fetchUsersByRole(rolesToFetch);
    setState(() {
      _patients = users;
      _isLoadingPatients = false;
    });
  }

  Future<void> _fetchSlots(DateTime day) async {
    setState(() => _isLoadingSlots = true);
    final slots = await repository.fetchAvailableSlots(day);
    setState(() {
      _availableSlots = slots;
      _isLoadingSlots = false;
      _selectedSlot = null;
    });
  }

  Future<void> _handleBook() async {
    if (_selectedSlot == null) return;

    final currentUserId = AuthService.instance.currentUser ?? 'guest';
    final patientId = _selectedPatientId ?? currentUserId;
    
    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      time: _selectedSlot!,
      status: 'pending',
      type: _selectedType,
      reason: _reasonCtrl.text.trim(),
      providerId: currentUserId, // Staff member booking it
    );

    final success = await repository.createAppointment(appointment);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFF003366);
    final accentColor = const Color(0xFFFFB81C);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Book Appointment', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(primaryColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSectionTitle('1. Select Date'),
                  const SizedBox(height: 12),
                  _buildCalendarCard(primaryColor, accentColor),
                  const SizedBox(height: 24),
                  _buildPatientSelector(),
                  _buildSectionTitle('2. Select Service'),
                  const SizedBox(height: 12),
                  _buildTypeSelector(primaryColor, accentColor),
                  const SizedBox(height: 24),
                  _buildSectionTitle('3. Reason for Visit'),
                  const SizedBox(height: 12),
                  _buildReasonInput(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('4. Available Slots'),
                  const SizedBox(height: 12),
                  _buildSlotsGrid(accentColor),
                  const SizedBox(height: 32),
                  if (_selectedSlot != null) _buildConfirmButton(primaryColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan Your Visit',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Book a professional session with our healthcare specialists.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildCalendarCard(Color primaryColor, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 30)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _fetchSlots(selectedDay);
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: accentColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          outsideDaysVisible: false,
        ),
      ),
    );
  }

  Widget _buildPatientSelector() {
    final role = AuthService.instance.userRole.value;
    if (role == UserRole.student) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Staff Only: Select Patient'),
        const SizedBox(height: 12),
        if (_isLoadingPatients)
          const Center(child: CircularProgressIndicator())
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPatientId,
                hint: const Text('Choose a person...'),
                isExpanded: true,
                items: _patients.map((p) {
                  return DropdownMenuItem<String>(
                    value: p['id'],
                    child: Text(p['name']!),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedPatientId = val;
                    _selectedPatientName = _patients.firstWhere((p) => p['id'] == val)['name'];
                  });
                },
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTypeSelector(Color primaryColor, Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: _ServiceCard(
            title: 'Psychiatrist',
            icon: Icons.psychology,
            isSelected: _selectedType == 'psychiatrist',
            onTap: () => setState(() => _selectedType = 'psychiatrist'),
            primaryColor: primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ServiceCard(
            title: 'Gen. Practitioner',
            icon: Icons.medical_services,
            isSelected: _selectedType == 'gp',
            onTap: () => setState(() => _selectedType = 'gp'),
            primaryColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonInput() {
    return TextField(
      controller: _reasonCtrl,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Briefly describe why you are booking this appointment...',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.all(16),
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
          borderSide: BorderSide(color: const Color(0xFF003366).withOpacity(0.5), width: 2),
        ),
      ),
    );
  }

  Widget _buildSlotsGrid(Color accentColor) {
    if (_isLoadingSlots) {
      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    }
    if (_availableSlots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No slots available for this day. Please select another date.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _availableSlots.length,
      itemBuilder: (context, index) {
        final slot = _availableSlots[index];
        final isSelected = _selectedSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = isSelected ? null : slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? accentColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? accentColor : Colors.grey[300]!,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmButton(Color primaryColor) {
    return ElevatedButton(
      onPressed: _handleBook,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline),
          SizedBox(width: 12),
          Text(
            'Confirm Appointment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _ServiceCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[200]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
