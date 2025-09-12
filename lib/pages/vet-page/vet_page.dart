// lib/pages/vet-page/vet_page.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// 🔹 Added imports
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

final MapController _mapController = MapController();

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

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Map state
  bool _showMap = false;
  LatLng _mapCenter = LatLng(12.9716, 77.5946); // default center
  double _mapZoom = 13.0;

  // 🔹 Added fields
  List<Marker> _vetMarkers = [];
  Timer? _debounce;

  // Get current user's UID
  String? get _userId => _auth.currentUser?.uid;

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
    if (_userId == null) {
      return;
    }

    try {
      await _firestore.collection('vethistory').doc(_userId).set({
        'visitDays': _visitDays.map((d) => d.toIso8601String()).toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving visit days: $e');
    }
  }

  Future<void> _saveScheduledPetVisits() async {
    if (_userId == null) return;

    try {
      await _firestore.collection('vethistory').doc(_userId).set({
        'scheduledPetVisits':
            _scheduledPetVisits.map((d) => d.toIso8601String()).toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving scheduled pet visits: $e');
    }
  }

  Future<void> _saveVets() async {
    if (_userId == null) return;

    try {
      await _firestore.collection('vethistory').doc(_userId).set({
        'vets': _vets,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving vets: $e');
    }
  }

  Future<void> _loadVisitDays() async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('vethistory').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('visitDays')) {
          final visitDaysList = List<String>.from(data['visitDays'] ?? []);
          setState(() {
            _visitDays.clear();
            _visitDays
                .addAll(visitDaysList.map((s) => DateTime.parse(s)).toList());
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading visit days: $e');
    }
  }

  Future<void> _loadScheduledPetVisits() async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('vethistory').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('scheduledPetVisits')) {
          final scheduledList =
              List<String>.from(data['scheduledPetVisits'] ?? []);
          setState(() {
            _scheduledPetVisits.clear();
            _scheduledPetVisits
                .addAll(scheduledList.map((s) => DateTime.parse(s)).toList());
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading scheduled pet visits: $e');
    }
  }

  Future<void> _loadVets() async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('vethistory').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('vets')) {
          final vetsList = List<Map<String, dynamic>>.from(data['vets'] ?? []);
          setState(() {
            _vets.clear();
            _vets.addAll(vetsList.map((vet) {
              return {
                'name': (vet['name'] ?? '').toString(),
                'phone': (vet['phone'] ?? '').toString(),
                'location': (vet['location'] ?? '').toString(),
              };
            }).toList());
          });
        }
      }

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
      debugPrint('Error loading vets: $e');
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

  /* ───────────────────────────── Overpass API ───────────────────────────────── */

  Future<void> _fetchNearbyVets(LatLngBounds bounds) async {
    final south = bounds.south;
    final west = bounds.west;
    final north = bounds.north;
    final east = bounds.east;

    final overpassUrl = Uri.parse(
      "https://overpass-api.de/api/interpreter?data=[out:json];"
      "node[\"amenity\"=\"veterinary\"]($south,$west,$north,$east);out;"
    );

    try {
      final response = await http.get(overpassUrl);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List;

        setState(() {
          _vetMarkers = elements.map((e) {
            final lat = e['lat'] as double;
            final lon = e['lon'] as double;
            final name = e['tags']?['name'] ?? "Veterinarian";

            return Marker(
              width: 60,
              height: 60,
              point: LatLng(lat, lon),
              child: Tooltip(
                message: name,
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Overpass fetch error: $e");
    }
  }

  /* ───────────────────────────── UI ──────────────────────────────────────── */

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Please log in to view your vet information'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return _visitDays.any((d) => isSameDay(d, day)) ||
                  _scheduledPetVisits.any((d) => isSameDay(d, day));
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
              _toggleVisitDay(selectedDay);
            },
            calendarFormat: CalendarFormat.month,
            onFormatChanged: (_) {},
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Vet Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  if (_vets.length < _maxVets)
                    IconButton(
                      tooltip: 'Add vet',
                      icon: const Icon(Icons.add),
                      onPressed: _addVet,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          ..._vets.asMap().entries.map((entry) {
            final idx = entry.key;
            final v = entry.value;
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(v['name'] ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(v['phone'] ?? ''),
                    const SizedBox(height: 2),
                    Text(v['location'] ?? ''),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.teal),
                      onPressed: () => _editVet(idx),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Vet'),
                            content: const Text(
                                'Are you sure you want to delete this vet?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel')),
                              ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          setState(() {
                            _vets.removeAt(idx);
                          });
                          await _saveVets();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 16),

          Center(
            child: ElevatedButton.icon(
              icon: Icon(_showMap ? Icons.map : Icons.map_outlined),
              label: Text(_showMap ? 'Hide Map' : 'Find Nearby Vets'),
              onPressed: () {
                setState(() {
                  _showMap = !_showMap;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          if (_showMap)
            SizedBox(
              height: 320,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _mapCenter,
                  zoom: _mapZoom,
                  onMapReady: () {
                    final bounds = _mapController.camera.visibleBounds;
                    if (bounds != null) {
                      _fetchNearbyVets(bounds);
                    }
                  },
                  onPositionChanged: (camera, hasGesture) {
                    final bounds = MapController().camera.visibleBounds;
                    if (bounds != null) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(seconds: 2), () {
                        _fetchNearbyVets(bounds);
                      });
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.pet_health',
                  ),
                  MarkerLayer(markers: _vetMarkers),
                ],
              ),

              ),
            ],),
        
    
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

}
