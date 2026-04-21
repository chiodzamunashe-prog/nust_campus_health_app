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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _selectedSlot;
  List<DateTime> _availableSlots = [];
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    _fetchSlots(DateTime.now());
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

    final studentId = AuthService.instance.currentUser ?? 'student_1'; // Use auth or fallback
    
    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: studentId,
      time: _selectedSlot!,
      status: 'pending',
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
      body: Column(
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
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Available Slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: _isLoadingSlots
                ? const Center(child: CircularProgressIndicator())
                : _availableSlots.isEmpty
                    ? const Center(child: Text('No slots available for this day.'))
                    : GridView.builder(
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
          ),
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
    );
  }
}
