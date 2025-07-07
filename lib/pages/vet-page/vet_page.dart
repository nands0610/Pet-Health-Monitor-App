import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VetPage extends StatefulWidget {
  const VetPage({Key? key}) : super(key: key);

  @override
  State<VetPage> createState() => _VetPageState();
}

class _VetPageState extends State<VetPage> {
  DateTime _focusedDay = DateTime.now();
  final List<DateTime> _visitDays = [];
  String _vetName = 'Dr. Jane Doe';
  String _vetPhone = '+91 9876543210';
  String _vetLocation = 'Chennai';

  @override
  void initState() {
    super.initState();
    _loadVetInfo();
    _loadVisitDays();
  }

  void _showNearBy() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 300,
        child: const Center(child: Text('Nearby Vets Map Placeholder')),
      ),
    );
  }

  void _toggleVisitDay(DateTime day) {
    setState(() {
      final index = _visitDays.indexWhere((d) => isSameDay(d, day));
      if (index >= 0) {
        _visitDays.removeAt(index);
      } else {
        _visitDays.add(day);
      }
      _saveVisitDays();
    });
  }

  Future<void> _saveVisitDays() async {
    final prefs = await SharedPreferences.getInstance();
    final strings = _visitDays.map((d) => d.toIso8601String()).toList();
    prefs.setString('visitDays', jsonEncode(strings));
  }

  Future<void> _loadVisitDays() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('visitDays');
    if (data != null) {
      final list = List<String>.from(jsonDecode(data));
      setState(() {
        _visitDays.clear();
        _visitDays.addAll(list.map((s) => DateTime.parse(s)));
      });
    }
  }

  Future<void> _loadVetInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vetName = prefs.getString('vetName') ?? _vetName;
      _vetPhone = prefs.getString('vetPhone') ?? _vetPhone;
      _vetLocation = prefs.getString('vetLocation') ?? _vetLocation;
    });
  }

  Future<void> _editVetInfo() async {
    final nameController = TextEditingController(text: _vetName);
    final phoneController = TextEditingController(text: _vetPhone);
    final locationController = TextEditingController(text: _vetLocation);

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Vet Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vetName', nameController.text);
      await prefs.setString('vetPhone', phoneController.text);
      await prefs.setString('vetLocation', locationController.text);

      setState(() {
        _vetName = nameController.text;
        _vetPhone = phoneController.text;
        _vetLocation = locationController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.local_hospital),
              title: Text(_vetName),
              subtitle: Text('Phone: $_vetPhone\n$_vetLocation'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editVetInfo,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showNearBy,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Show Nearby Vets'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Vet Visits',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => _visitDays.any((d) => isSameDay(d, day)),
            onDaySelected: (selectedDay, focusedDay) {
              _focusedDay = focusedDay;
              _toggleVisitDay(selectedDay);
            },
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.teal.shade100, shape: BoxShape.circle),
              selectedDecoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
              markerDecoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (_visitDays.any((d) => isSameDay(d, date))) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_visitDays.isNotEmpty) ...[
            Text(
              'Vet Visit History',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _visitDays.length,
              itemBuilder: (context, index) {
                final sortedDates = _visitDays.toList()
                  ..sort((a, b) => b.compareTo(a)); // Most recent first
                final d = sortedDates[index];
                return ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text('${d.day}/${d.month}/${d.year}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _visitDays.removeWhere((v) => isSameDay(v, d));
                        _saveVisitDays();
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
