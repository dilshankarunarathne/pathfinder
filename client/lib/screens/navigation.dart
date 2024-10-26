import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:location/location.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  MapBoxNavigationViewController? _controller;
  String? _instruction;
  final bool _isMultipleStop = false;
  double? _distanceRemaining, _durationRemaining;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  bool _arrived = false;
  late MapBoxOptions _navigationOption;
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  List<Map<String, dynamic>> _nearbyPlaces = [];

  Future<void> initialize() async {
    if (!mounted) return;
    _navigationOption = MapBoxNavigation.instance.getDefaultOptions();
    // Set your desired initial latitude and longitude
    _navigationOption.initialLatitude = 8.6538461;
    _navigationOption.initialLongitude = 81.2083256;
    _navigationOption.mode =
        MapBoxNavigationMode.driving; // Change mode if needed
    MapBoxNavigation.instance.registerRouteEventListener(_onRouteEvent);
  }

  @override
  void initState() {
    initialize();
    _initSpeech();
    super.initState();
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
    _startListeningLoop(); // Start the listening loop
  }

  void _startListeningLoop() async {
    while (mounted) {
      if (!_isListening) {
        await _startListening();
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      await _speechToText.listen(onResult: _onSpeechResult);
      print('Listening...');
      setState(() {
        _isListening = true;
      });
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final recognizedWords = result.recognizedWords.toLowerCase();
    print('--------------------Recognized words: $recognizedWords');
    if (recognizedWords.contains('go back')) {
      Navigator.pop(context);
    } else if (recognizedWords.contains('camera')) {
      Navigator.pushNamed(context, '/roam_mode');
    } else if (recognizedWords.startsWith('navigate to ')) {
      final placeName = recognizedWords.replaceFirst('navigate to ', '').trim();
      print("**********************$placeName");
      _navigateToPlace(placeName);
    }
  }

  Future<void> _navigateToPlace(String placeName) async {
    print("------------------ navigating to place: $placeName");
    print('----------------Fetching nearby places...');
    await _fetchNearbyPlaces();
    print('------------------Nearby places fetched: $_nearbyPlaces');
    final place = _nearbyPlaces.firstWhere(
      (place) => place['name'].toLowerCase() == placeName.toLowerCase(),
      orElse: () => {},
    );

    if (place.isNotEmpty) {
      final double destinationLatitude = place['latitude'];
      final double destinationLongitude = place['longitude'];
      print(
          "****----------------- voice command navigation successful $destinationLatitude");

      await _startNavigation(destinationLatitude, destinationLongitude);
    } else {
      print('----------------- Place not found');
    }
  }

  Future<void> _fetchNearbyPlaces() async {
    try {
      final String response = await rootBundle.loadString('assets/campus.json');
      final data = json.decode(response);
      final features = data['features'] as List<dynamic>;

      print('---------------------------- got Features');

      setState(() {
        _nearbyPlaces = features
            .map((feature) {
              final name = feature['properties']['name'];
              final latitude = feature['geometry']['coordinates'][1];
              final longitude = feature['geometry']['coordinates'][0];

              if (name != null && latitude != null && longitude != null) {
                return {
                  'name': name as String,
                  'latitude': latitude as double,
                  'longitude': longitude as double,
                };
              } else {
                return null;
              }
            })
            .where((place) => place != null)
            .cast<Map<String, dynamic>>()
            .toList();

        print('Nearby places: $_nearbyPlaces');
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: Column(
        children: [
          SizedBox(
            width: 200, // Set the desired width
            height: 200, // Set the desired height
            child: Image.asset(
                'assets/images/logo.jpg'), // Add the logo at the top
          ),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: MapBoxNavigationView(
                options: _navigationOption,
                onRouteEvent: _onRouteEvent,
                onCreated: (MapBoxNavigationViewController controller) async {
                  _controller = controller;
                  controller.initialize();
                },
              ),
            ),
          ),
          // Add any additional navigation controls here (optional)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Button to start navigation (if needed)
                ElevatedButton(
                  onPressed: () => _startNavigation(
                      8.655370, 81.21151), // Example coordinates
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF004D40), // Text color
                  ),
                  child: const Text('Start Navigation'),
                ),
                const Spacer(),
                // Additional controls like zoom or map type (optional)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startNavigation(
      double destinationLatitude, double destinationLongitude) async {
    // Get the current location
    Location location = Location();

    // Check if location services are enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check for location permissions
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData currentLocation = await location.getLocation();

    // Create WayPoint objects for the current location and the destination
    final start = WayPoint(
      latitude: currentLocation.latitude!,
      longitude: currentLocation.longitude!,
      name: 'Start',
    );
    final destination = WayPoint(
      latitude: destinationLatitude,
      longitude: destinationLongitude,
      name: 'Destination',
    );

    // Implement your navigation logic here
    if (_isMultipleStop) {
      // Add your waypoints logic here for multiple stops
    } else {
      // Single stop navigation
      // Use the start and destination WayPoint objects
      await _navigateToDestination(start, destination);
    }
  }

  // Example method to navigate to a destination
  Future<void> _navigateToDestination(
      WayPoint start, WayPoint destination) async {
    // Implement the actual navigation logic here
    print(
        'Navigating from: ${start.name} (${start.latitude}, ${start.longitude}) to ${destination.name} (${destination.latitude}, ${destination.longitude})');

    // Start navigation using MapBoxNavigation
    await MapBoxNavigation.instance.startNavigation(
      wayPoints: [start, destination],
      options: MapBoxOptions(
        mode: MapBoxNavigationMode.driving,
        simulateRoute: false,
        language: "en",
        units: VoiceUnits.metric,
      ),
    );
  }

  Future<void> _onRouteEvent(e) async {
    _distanceRemaining = await MapBoxNavigation.instance.getDistanceRemaining();
    _durationRemaining = await MapBoxNavigation.instance.getDurationRemaining();

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived!;
        if (progressEvent.currentStepInstruction != null) {
          _instruction = progressEvent.currentStepInstruction;
        }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (!_isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
          await _controller?.finishNavigation();
        }
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _routeBuilt = false;
        _isNavigating = false;
        break;
      default:
        break;
    }
    //refresh UI
    setState(() {});
  }
}
