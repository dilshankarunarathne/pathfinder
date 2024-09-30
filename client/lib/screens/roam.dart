import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class Navigation extends StatefulWidget {
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  GoogleMapController? _controller;

  static final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // Example coordinates (San Francisco)
    zoom: 14.4746,
  );

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  void _toggleAudioOutput() {
    // Implement the logic to toggle audio output
    print("Audio output toggled");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAudioOutput,
        child: Icon(Icons.volume_up),
      ),
    );
  }
}
