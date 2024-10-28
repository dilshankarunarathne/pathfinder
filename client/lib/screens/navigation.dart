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
    super.initState();
    initialize();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      bool available = await _speechToText.initialize();
      if (available) {
        _startListening(); // Start listening automatically
      } else {
        print("The user has denied the use of speech recognition.");
      }
    } catch (e) {
      print("Error initializing speech recognition: $e");
    }
  }

  void _startListening() async {
    if (!_isListening) {
      try {
        await _speechToText.listen(
          onResult: _onSpeechResult,
          listenFor: const Duration(seconds: 5),
          pauseFor:
              const Duration(seconds: 5), // Pause duration between phrases
        );
        print('Listening...');
        setState(() {
          _isListening = true;
        });
      } catch (e) {
        print("Error starting listening: $e");
      }
    }
  }

  void _stopListening() async {
    if (_isListening) {
      try {
        await _speechToText.stop();
        setState(() {
          _isListening = false;
        });
      } catch (e) {
        print("Error stopping listening: $e");
      }
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) async {
    final recognizedWords = result.recognizedWords.toLowerCase();
    print('Recognized words: $recognizedWords');
    try {
      if (recognizedWords.contains('go back')) {
        print('-------------------Going back');
        Navigator.pop(context);
      } else if (recognizedWords.contains('camera')) {
        Navigator.pushNamed(context, '/roam_mode');
      } else if (recognizedWords.contains('home')) {
        Navigator.pushNamed(context, '/');
        // } else if (recognizedWords.startsWith('navigate to ')) {
        //   final placeName =
        //       recognizedWords.replaceFirst('navigate to ', '').trim();
        //   print("-----------------------Navigating to: $placeName");
        //   _navigateToPlace(placeName);
        // }
      } else {
        print('--------------recognized: $recognizedWords');
        print('----------- navigating to $recognizedWords');
        _navigateToPlace(recognizedWords.toLowerCase());
      }
    } catch (e) {
      print("Error processing speech result: $e");
    }

    // Stop listening and wait for 2 seconds before restarting
    _stopListening();
    await Future.delayed(const Duration(seconds: 2));
    _startListening();
  }

  Future<void> _navigateToPlace(String placeName) async {
    print("Navigating to place: $placeName");
    print('Fetching nearby places...');
    await _fetchNearbyPlaces();
    print('Nearby places fetched: $_nearbyPlaces');
    final place = _nearbyPlaces.firstWhere(
      (place) => place['name'].toLowerCase() == placeName.toLowerCase(),
      orElse: () => {},
    );

    if (place.isNotEmpty) {
      final double destinationLatitude = place['latitude'];
      final double destinationLongitude = place['longitude'];
      print("Voice command navigation successful: $destinationLatitude");

      await _startNavigation(destinationLatitude, destinationLongitude);
    } else {
      print('Place not found');
    }
  }

  Future<void> _fetchNearbyPlaces() async {
    try {
      final String response = await rootBundle.loadString('assets/campus.json');
      final data = json.decode(response);
      final features = data['features'] as List<dynamic>;

      print('Got features');

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
      print("Error fetching nearby places: $e");
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
            width: 200,
            height: 200,
            child: Image.asset('assets/images/logo.png'),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startNavigation(
      double destinationLatitude, double destinationLongitude) async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData currentLocation = await location.getLocation();

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

    if (_isMultipleStop) {
      // Add your waypoints logic here for multiple stops
    } else {
      await _navigateToDestination(start, destination);
    }
  }

  Future<void> _navigateToDestination(
      WayPoint start, WayPoint destination) async {
    print(
        'Navigating from: ${start.name} (${start.latitude}, ${start.longitude}) to ${destination.name} (${destination.latitude}, ${destination.longitude})');

    try {
      await MapBoxNavigation.instance.startNavigation(
        wayPoints: [start, destination],
        options: MapBoxOptions(
          mode: MapBoxNavigationMode.driving,
          simulateRoute: false,
          language: "en",
          units: VoiceUnits.metric,
        ),
      );
    } catch (e) {
      print("Error starting navigation: $e");
    }
  }

  Future<void> _onRouteEvent(e) async {
    try {
      _distanceRemaining =
          await MapBoxNavigation.instance.getDistanceRemaining();
      _durationRemaining =
          await MapBoxNavigation.instance.getDurationRemaining();

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
      setState(() {});
    } catch (e) {
      print("Error handling route event: $e");
    }
  }
}
