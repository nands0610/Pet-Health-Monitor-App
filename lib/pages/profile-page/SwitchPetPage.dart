import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_health/main.dart';
import 'package:pet_health/pages/auth-pages/pet_details_page.dart';

class SwitchPetPage extends StatefulWidget {
  const SwitchPetPage({super.key});

  @override
  State<SwitchPetPage> createState() => _SwitchPetPageState();
}

class _SwitchPetPageState extends State<SwitchPetPage> {
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final activePetId = userDoc.data()?['activePetId'] as String?;

    final petsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pets')
        .get();

    return {
      'activePetId': activePetId,
      'pets': petsSnapshot.docs,
    };
  }

  Future<void> _setActivePet(String petId) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'activePetId': petId,
    });
    setState(() {}); // refresh the page
  }

  Future<void> _addNewPet() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userDoc.data();
    if (userData != null) {
      final userName = userData['name'] ?? 'User';
      final userPhone = userData['phone'] ?? '';

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PetDetailsPage(
            name: userName,
            phone: userPhone,
          ),
        ),
      ).then((_) {
        // Refresh list when returning from add page
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Pet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Pet',
            onPressed: _addNewPet,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading pets'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final activePetId = snapshot.data?['activePetId'] as String?;
          final pets = snapshot.data?['pets'] as List<QueryDocumentSnapshot>;

          if (pets.isEmpty) {
            return const Center(child: Text('No pets found.'));
          }

          return ListView(
            children: pets.map((doc) {
              var pet = doc.data() as Map<String, dynamic>;
              String petName = pet['name'] ?? 'Unknown';
              String? photoUrl = pet['photoUrl'];
              bool isActive = doc.id == activePetId;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : const AssetImage('assets/pet_icon.png') as ImageProvider,
                ),
                title: Text(petName),
                trailing: isActive ? const Icon(Icons.check, color: Colors.teal) : null,
                tileColor: isActive ? Colors.teal.withOpacity(0.1) : null,
                onTap: () async {
                  await _setActivePet(doc.id);
                  if (!mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainScaffold()),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
