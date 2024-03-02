import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart'; // Import your AuthProvider

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the AuthProvider using Provider.of
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Screen'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(authProvider.user?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic> data = snapshot.data?.data() as Map<String, dynamic>;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Profile Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text('Name: ${data['name']}'),
                  Text('Email: ${data['email']}'),
                  // Display other user details as needed
                  SizedBox(height: 20),
                  // Display profile picture
                  data['profilePicture'].isNotEmpty
                      ? Image.network(
                          data['profilePicture'],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
