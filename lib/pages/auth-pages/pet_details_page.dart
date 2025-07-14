import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../main.dart';

class PetDetailsPage extends StatefulWidget {
  final String name;
  final String phone;

  const PetDetailsPage({Key? key, required this.name, required this.phone}) : super(key: key);

  @override
  State<PetDetailsPage> createState() => _PetDetailsPageState();
}

class _PetDetailsPageState extends State<PetDetailsPage> {
  final _petNameController = TextEditingController();
  final _typeController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  String _sex = 'Male';
  File? _petImage;
  bool _isLoading = false;
  String? _error;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() {
        _petImage = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      String? photoUrl;
      if (_petImage != null) {
        final ref = FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/pet_photo.jpg');
        await ref.putFile(_petImage!);
        photoUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': widget.name,
        'phone': widget.phone,
        'email': user.email,
        'pet': {
          'name': _petNameController.text.trim(),
          'type': _typeController.text.trim(),
          'breed': _breedController.text.trim(),
          'weight': _weightController.text.trim(),
          'sex': _sex,
          'photoUrl': photoUrl,
        },
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              TextField(
                controller: _petNameController,
                decoration: const InputDecoration(labelText: 'Pet Name'),
              ),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type (e.g., Dog, Cat)'),
              ),
              TextField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'Breed'),
              ),
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>(
                value: _sex,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) => setState(() => _sex = value!),
              ),
              const SizedBox(height: 12),
              _petImage != null
                  ? Image.file(_petImage!, height: 150)
                  : const Text('No photo selected'),
              TextButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text('Pick Pet Photo'),
                onPressed: _pickPhoto,
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
