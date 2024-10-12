import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Email: yourname@gmail.com'),
            ElevatedButton(
              onPressed: () {
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
