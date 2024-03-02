import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  List<PlatformFile> _files = [];
  String _errorText = '';

  void _pickFiles() async {
    FilePickerResult? files = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (files != null) {
      setState(() {
        _files = files.files;
      });
    }
  }

  Future<String?> _uploadFiles(String userId) async {
    if (_files.isEmpty) return null;

    List<String> fileUrls = [];

    try {
      for (PlatformFile file in _files) {
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('userFiles/$userId/${file.name}');
        await ref.putFile(File(file.path!));

        String downloadUrl = await ref.getDownloadURL();
        fileUrls.add(downloadUrl);
      }
    } catch (e) {
      print('Error uploading files: $e');
      return null;
    }

    return fileUrls.join(',');
  }

  Future<void> _submitProfile() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      String userId = user.uid;

      String? fileUrls = await _uploadFiles(userId);

      if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
        setState(() {
          _errorText = 'Name and Email cannot be empty.';
        });
        return;
      }

      await _firestore.collection('users').doc(userId).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'fileUrls': fileUrls ?? '',
      });

      // Navigate to the home screen or any other screen after profile creation.
      // Replace '/homeScreen' with the desired route.
      Navigator.pushReplacementNamed(context, '/profileScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Creation'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Profile Creation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 118, 117, 117),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 5,
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [

                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 16.0),
                      if (_errorText.isNotEmpty)
                        Text(
                          _errorText,
                          style: TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _pickFiles,
                        child: const Text('Select Profile Photo'),
                      ),
                      if (_files.isNotEmpty)
                        Column(
                          children: _files.map((file) {
                            return Text(file.name);
                          }).toList(),
                        ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _submitProfile,
                        child: const Text('Submit Profile'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
