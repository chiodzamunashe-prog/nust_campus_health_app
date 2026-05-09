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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
          TableCalendar(
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
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(color: Color(0xFF003366), shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: Color(0xFFFFB81C), shape: BoxShape.circle),
            ),
          ),
          const Divider(),
          _buildPatientSelector(),
          const Divider(),
          _buildTypeSelector(),
          const Divider(),
          _buildReasonInput(),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Available Slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _isLoadingSlots
              ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
              : _availableSlots.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text('No slots available for this day.')),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _availableSlots.length,
                      itemBuilder: (context, index) {
                        final slot = _availableSlots[index];
                        final isSelected = _selectedSlot == slot;
                        return ChoiceChip(
                          label: Text('${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}'),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() => _selectedSlot = val ? slot : null);
                          },
                          selectedColor: const Color(0xFFFFB81C),
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        );
                      },
                    ),
          const SizedBox(height: 20),
          if (_selectedSlot != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _handleBook,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSelector() {
    final role = AuthService.instance.userRole.value;
    if (role == UserRole.student) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Patient', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_isLoadingPatients)
            const CircularProgressIndicator()
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
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
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Psychiatrist'),
                  selected: _selectedType == 'psychiatrist',
                  onSelected: (val) => setState(() => _selectedType = 'psychiatrist'),
                  selectedColor: const Color(0xFF003366),
                  labelStyle: TextStyle(color: _selectedType == 'psychiatrist' ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text('General Practitioner'),
                  selected: _selectedType == 'gp',
                  onSelected: (val) => setState(() => _selectedType = 'gp'),
                  selectedColor: const Color(0xFF003366),
                  labelStyle: TextStyle(color: _selectedType == 'gp' ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReasonInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reason for Visit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonCtrl,
            decoration: InputDecoration(
              hintText: 'Briefly describe why you are booking this appointment...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 2,
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
