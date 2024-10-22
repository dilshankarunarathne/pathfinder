import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  MapBoxNavigationViewController? _controller;
  String? _instruction;
  final bool _isMultipleStop = false; // Change to true for multiple stops
  double? _distanceRemaining, _durationRemaining;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  bool _arrived = false;
  late MapBoxOptions _navigationOption;

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
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
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
          // SizedBox(
          //   width: 200, // Set the desired width
          //   height: 200, // Set the desired height
          //   child: Image.asset(
          //       'assets/images/logo.jpg'), // Add the logo at the top
          // ),
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
                  onPressed: () =>
                      _startNavigation(), // Implement navigation logic
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

  Future<void> _startNavigation() async {
    // Implement your navigation logic here
    // For example, define your waypoints for multiple stops
    if (_isMultipleStop) {
      // ... Add your waypoints logic here ...
    } else {
      // Single stop navigation (replace with your destination)
      final destination = WayPoint(
        name: 'Your Destination Name',
        latitude: 37.7749, // Replace with your destination latitude
        longitude: -122.4194, // Replace with your destination longitude
      );
      await _controller?.buildRoute(wayPoints: [destination]);
      await _controller?.startNavigation();
    }
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
