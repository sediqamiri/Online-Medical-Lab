import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/test_cart_provider.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;

  final List<String> _timeSlots = [
    "08:00 AM",
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "01:00 PM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM"
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Book Appointment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Date",
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
            const SizedBox(height: 30),
            Text("Select Time Slot",
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTime == _timeSlots[index];
                return ChoiceChip(
                  label: Text(_timeSlots[index]),
                  selected: isSelected,
                  onSelected: (val) =>
                      setState(() => _selectedTime = _timeSlots[index]),
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black),
                );
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _selectedTime == null
                    ? null
                    : () async => _confirmBooking(),
                child: const Text("CONFIRM BOOKING",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cart = Provider.of<TestCartProvider>(context, listen: false);
    final scheduledAt = _buildScheduledDateTime();
    final selectedTests =
        cart.selectedTests.map((test) => test.name).toList(growable: false);

    await auth.addAppointment(
      labName: 'Online Medical Lab',
      scheduledAt: scheduledAt,
      testNames: selectedTests,
    );
    cart.clear();

    if (!mounted) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Text(
          "Appointment booked successfully for ${DateFormat('dd MMM yyyy, hh:mm a').format(scheduledAt)}.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  DateTime _buildScheduledDateTime() {
    final parsedTime = DateFormat('hh:mm a').parse(_selectedTime!);
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      parsedTime.hour,
      parsedTime.minute,
    );
  }
}
