import 'package:flutter/material.dart';

class RoamingModeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roaming Mode'),
      ),
      body: Center(
        child: Container(
          width: 375,
          height: 523,
          color: Colors.grey[300], // Placeholder for Camera feed
          child: Center(child: Text("Camera Feed")),
        ),
      ),
    );
  }
}
