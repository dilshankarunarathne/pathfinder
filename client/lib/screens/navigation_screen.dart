import 'package:flutter/material.dart';

class NavigationModeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation Mode'),
      ),
      body: Center(
        child: Container(
          width: 375,
          height: 523,
          color: Colors.grey[300], // Placeholder for Map/GPS view
          child: Center(child: Text("Map View")),
        ),
      ),
    );
  }
}
