import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class VetPage extends StatefulWidget {
  const VetPage({Key? key}) : super(key: key);

  @override
  State<VetPage> createState() => _VetPageState();
}

class _VetPageState extends State<VetPage> {
  // Calendar state
  DateTime _focusedDay = DateTime.now();
  final List<DateTime> _visitDays = [];
  final List<DateTime> _scheduledPetVisits = [];

  // Vet contacts (max 3)
  final int _maxVets = 3;
  final List<Map<String, String>> _vets = [];

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = 'user_default'; // Replace with actual user ID when auth is implemented

  @override
  void initState() {
    super.initState();
    _loadVets();
    _loadVisitDays();
    _loadScheduledPetVisits();
  }

  /* ───────────────────────────── Calendar Helpers ─────────────────────────── */

  bool _isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    return selected.isAfter(today);
  }

  void _toggleVisitDay(DateTime day) {
    if (_isFutureDate(day)) {
      final exists = _scheduledPetVisits.any((d) => isSameDay(d, day));
      setState(() {
        if (exists) {
          _scheduledPetVisits.removeWhere((d) => isSameDay(d, day));
        } else {
          _scheduledPetVisits.add(day);
        }
        _saveScheduledPetVisits();
      });
    } else {
      final index = _visitDays.indexWhere((d) => isSameDay(d, day));
      setState(() {
        if (index >= 0) {
          _visitDays.removeAt(index);
        } else {
          _visitDays.add(day);
        }
        _saveVisitDays();
      });
    }
  }

  /* ───────────────────────────── Firebase Persistence ──────────────────────────────── */

  Future<void> _saveVisitDays() async {
    try {
      await _firestore.collection('vethistory').doc(_userId).set({
        'visitDays': _visitDays.map((d) => d.toIso8601String()).toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving visit days: $e');
    }
  }

  Future<void> _saveScheduledPetVisits() async {
    try {
      await _firestore.collection('vethistory').doc(_userId).set({
        'scheduledPetVisits': _scheduledPetVisits.map((d) => d.toIso8601String()).toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving scheduled pet visits: $e');
    }
  }

  Future<void> _saveVets() async {
    try {
      await _firestore.collection('vethistory').doc(_userId).set({
        'vets': _vets,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving vets: $e');
    }
  }

  Future<void> _loadVisitDays() async {
    try {
      final doc = await _firestore.collection('vethistory').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('visitDays')) {
          final visitDaysList = List<String>.from(data['visitDays'] ?? []);
          setState(() {
            _visitDays.clear();
            _visitDays.addAll(visitDaysList.map((s) => DateTime.parse(s)));
          });
        }
      }
    } catch (e) {
      print('Error loading visit days: $e');
    }
  }

  Future<void> _loadScheduledPetVisits() async {
    try {
      final doc = await _firestore.collection('vethistory').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('scheduledPetVisits')) {
          final scheduledList = List<String>.from(data['scheduledPetVisits'] ?? []);
          setState(() {
            _scheduledPetVisits.clear();
            _scheduledPetVisits.addAll(scheduledList.map((s) => DateTime.parse(s)));
          });
        }
      }
    } catch (e) {
      print('Error loading scheduled pet visits: $e');
    }
  }

  Future<void> _loadVets() async {
    try {
      final doc = await _firestore.collection('vethistory').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('vets')) {
          final vetsList = List<Map<String, dynamic>>.from(data['vets'] ?? []);
          setState(() {
            _vets.clear();
            _vets.addAll(vetsList.map((vet) => Map<String, String>.from(vet)));
          });
        }
      }
      // Ensure at least one default vet
      if (_vets.isEmpty) {
        setState(() {
          _vets.add({
            'name': 'Dr. Jane Doe',
            'phone': '+91 9876543210',
            'location': 'Chennai',
          });
        });
        await _saveVets();
      }
    } catch (e) {
      print('Error loading vets: $e');
      // Fallback to default vet if Firebase fails
      if (_vets.isEmpty) {
        setState(() {
          _vets.add({
            'name': 'Dr. Jane Doe',
            'phone': '+91 9876543210',
            'location': 'Chennai',
          });
        });
      }
    }
  }

  /* ───────────────────────────── Vet Editor ───────────────────────────────── */

  Future<void> _editVet(int index) async {
    final vet = _vets[index];
    final nameController = TextEditingController(text: vet['name']);
    final phoneController = TextEditingController(text: vet['phone']);
    final locationController = TextEditingController(text: vet['location']);

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Vet Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      setState(() {
        _vets[index] = {
          'name': nameController.text,
          'phone': phoneController.text,
          'location': locationController.text,
        };
      });
      await _saveVets();
    }
  }

  Future<void> _addVet() async {
    if (_vets.length >= _maxVets) return;

    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final locationController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Vet Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      setState(() {
        _vets.add({
          'name': nameController.text,
          'phone': phoneController.text,
          'location': locationController.text,
        });
      });
      await _saveVets();
    }
  }

  /* ───────────────────────────── UI ──────────────────────────────────────── */

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Vet Info Cards ──
          ..._vets.asMap().entries.map(
            (entry) {
              final idx = entry.key;
              final vet = entry.value;
              final isFirstCard = idx == 0;

              return Card(
                elevation: 3,
                margin: EdgeInsets.only(
                  top: isFirstCard ? 0 : 12,
                  bottom: 0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.local_hospital),
                  title: Text(vet['name'] ?? ''),
                  subtitle: Text(
                    'Phone: ${vet['phone']}\n${vet['location']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "+" button only on first card & only if room for more
                      if (isFirstCard && _vets.length < _maxVets)
                        IconButton(
                          tooltip: 'Add Vet',
                          icon: const Icon(Icons.add),
                          onPressed: _addVet,
                        ),
                      IconButton(
                        tooltip: 'Edit Vet',
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editVet(idx),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // ── Nearby Vets Button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showNearBy,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Show Nearby Vets'),
            ),
          ),
          const SizedBox(height: 24),

          // ── Calendar ──
          Text(
            'Vet Visits',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                _visitDays.any((d) => isSameDay(d, day)) ||
                _scheduledPetVisits.any((d) => isSameDay(d, day)),
            onDaySelected: (selectedDay, focusedDay) {
              _focusedDay = focusedDay;
              _toggleVisitDay(selectedDay);
            },
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.teal.shade100,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (_visitDays.any((d) => isSameDay(d, date))) {
                  return _buildMarker(Colors.red);
                }
                if (_scheduledPetVisits.any((d) => isSameDay(d, date))) {
                  return _buildMarker(Colors.blue);
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── Scheduled Visits ──
          if (_scheduledPetVisits.isNotEmpty) ...[
            Text(
              'Scheduled Pet Visits',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDateList(
              _scheduledPetVisits,
              icon: const Icon(Icons.event_available, color: Colors.blue),
              ascending: true,
              onRemove: (d) {
                _scheduledPetVisits.removeWhere((v) => isSameDay(v, d));
                _saveScheduledPetVisits();
              },
            ),
            const SizedBox(height: 16),
          ],

          // ── Visit History ──
          if (_visitDays.isNotEmpty) ...[
            Text(
              'Vet Visit History',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDateList(
              _visitDays,
              icon: const Icon(Icons.check_circle_outline),
              ascending: false,
              onRemove: (d) {
                _visitDays.removeWhere((v) => isSameDay(v, d));
                _saveVisitDays();
              },
            ),
          ],
        ],
      ),
    );
  }

  /* ───────────────────────────── Helpers ─────────────────────────────────── */

  Widget _buildMarker(Color color) => Positioned(
        right: 1,
        bottom: 1,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      );

  Widget _buildDateList(
    List<DateTime> dates, {
    required Widget icon,
    required bool ascending,
    required void Function(DateTime) onRemove,
  }) {
    final sorted = dates.toList()
      ..sort((a, b) => ascending ? a.compareTo(b) : b.compareTo(a));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final d = sorted[index];
        return ListTile(
          leading: icon,
          title: Text('${d.day}/${d.month}/${d.year}'),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              setState(() => onRemove(d));
            },
          ),
        );
      },
    );
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
}
