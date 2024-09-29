import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';

class NavigationModeScreen extends StatefulWidget {
  const NavigationModeScreen({super.key});

  @override
  _NavigationModeScreenState createState() => _NavigationModeScreenState();
}

class _NavigationModeScreenState extends State<NavigationModeScreen> {
  // ... (map initialization, speech recognition)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }
}
