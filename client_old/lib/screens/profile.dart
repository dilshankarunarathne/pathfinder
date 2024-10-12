import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Email: ${user?.email}'),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                // Navigate to login screen
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
