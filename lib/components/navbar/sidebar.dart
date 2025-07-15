import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_health/pages/auth-pages/splash_screen.dart';
import 'package:pet_health/pages/profile-page/SwitchPetPage.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Future<Map<String, dynamic>?> _petData;

  @override
  void initState() {
    super.initState();
    _petData = _fetchPetDetails();
  }

  Future<Map<String, dynamic>?> _fetchPetDetails() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists) return null;

    final userData = userDoc.data() as Map<String, dynamic>;
    final activePetId = userData['activePetId'];

    if (activePetId == null) return null;

    final petDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pets')
        .doc(activePetId)
        .get();

    if (!petDoc.exists) return null;

    return petDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _petData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading pet details'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No pet data found'));
          } else {
            final pet = snapshot.data!;
            final petName = pet['name'] ?? 'Unknown Pet';
            final petBreed = pet['breed'] ?? 'Unknown Breed';
            final photoUrl = pet['photoUrl'];

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  color: Colors.teal,
                  padding: const EdgeInsets.all(12),
                  height: 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                            ? NetworkImage(photoUrl)
                            : const AssetImage('assets/pet_icon.png') as ImageProvider,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            petName,
                            style: const TextStyle(color: Colors.white, fontSize: 22),
                          ),
                          Text(
                            petBreed,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.pets),
                  title: const Text('Switch Pet'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SwitchPetPage()),
                  );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const SplashScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
