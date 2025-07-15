import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SwitchPetPage extends StatelessWidget {
  const SwitchPetPage({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference petsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pets');

    return Scaffold(
      appBar: AppBar(title: const Text('Select a Pet')),
      body: StreamBuilder<QuerySnapshot>(
        stream: petsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading pets'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pets found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var pet = doc.data() as Map<String, dynamic>;
              String petName = pet['name'] ?? 'Unknown';
              String? photoUrl = pet['photoUrl'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : const AssetImage('assets/pet_icon.png') as ImageProvider,
                ),
                title: Text(petName),
                onTap: () {
                  // save selected pet ID locally
                  String petId = doc.id;

                  // You could use Provider, Riverpod, or just Navigator.push with petId
                  Navigator.pop(context, petId); 
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
