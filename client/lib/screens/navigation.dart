import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final _mapboxNavigation = MapBoxNavigation.instance;
  final _location = Location();
  bool _isNavigating = false;
  bool _isRouteBuilt = false;
  bool _isArrived = false;
  String? _instruction;
  double? _distanceRemaining;
  double? _durationRemaining;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Polyline? _polyline;
  MapBoxNavigationViewController? _controller;
  late MapBoxOptions _options;

  @override
  void initState() {
    super.initState();
    _registerNavigationEvents();
    _requestLocationPermission();
    _options = MapBoxOptions(
      initialLatitude: 42.886448,
      initialLongitude: -78.878372,
      zoom: 13.0,
      tilt: 0.0,
      bearing: 0.0,
      enableRefresh: false,
      alternatives: true,
      voiceInstructionsEnabled: true,
      bannerInstructionsEnabled: true,
      allowsUTurnAtWayPoints: true,
      mode: MapBoxNavigationMode.drivingWithTraffic,
      units: VoiceUnits.imperial,
      simulateRoute: false,
      language: "en",
    );
  }

  void _registerNavigationEvents() {
    _mapboxNavigation.registerRouteEventListener(_onRouteEvent);
  }

  Future<void> _requestLocationPermission() async {
    await _location.requestService();
    await _location.requestPermission();
  }

  void _onRouteEvent(RouteEvent e) {
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _isArrived = progressEvent.arrived!;
        if (progressEvent.currentStepInstruction != null) {
          _instruction = progressEvent.currentStepInstruction;
        }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        _isRouteBuilt = true;
        _updateMap(e); // Pass route event to _updateMap
        break;
      case MapBoxEvent.route_build_failed:
        _isRouteBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        _isArrived = true;
        Future.delayed(const Duration(seconds: 3), () async {
          await _controller?.finishNavigation();
        });
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _isRouteBuilt = false;
        _isNavigating = false;
        break;
      default:
        break;
    }

    setState(() {});
  }

  Future<void> _updateMap(RouteEvent routeEvent) async {
    if (_isRouteBuilt) {
      final route = routeEvent.data.routes.first;

      _polyline = Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: route.geometry.coordinates
            .map((coords) => LatLng(coords[1], coords[0]))
            .toList(),
      );

      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('start'),
        position: LatLng(route.geometry.coordinates.first[1],
            route.geometry.coordinates.first[0]),
        infoWindow: const InfoWindow(title: 'Start'),
      ));
      _markers.add(Marker(
        markerId: const MarkerId('end'),
        position: LatLng(route.geometry.coordinates.last[1],
            route.geometry.coordinates.last[0]),
        infoWindow: const InfoWindow(title: 'End'),
      ));

      LatLngBounds bounds = _createLatLngBoundsFromMarkers(_markers);
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }

    setState(() {});
  }

  LatLngBounds _createLatLngBoundsFromMarkers(Set<Marker> markers) {
    double southWestLat = markers.first.position.latitude;
    double southWestLng = markers.first.position.longitude;
    double northEastLat = markers.first.position.latitude;
    double northEastLng = markers.first.position.longitude;

    for (var marker in markers) {
      if (marker.position.latitude < southWestLat) {
        southWestLat = marker.position.latitude;
      }
      if (marker.position.longitude < southWestLng) {
        southWestLng = marker.position.longitude;
      }
      if (marker.position.latitude > northEastLat) {
        northEastLat = marker.position.latitude;
      }
      if (marker.position.longitude > northEastLng) {
        northEastLng = marker.position.longitude;
      }
    }

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  Future<void> _startNavigation() async {
    final cityHall =
        WayPoint(name: 'City Hall', latitude: 42.886448, longitude: -78.878372);
    final downtown = WayPoint(
        name: 'Downtown Buffalo', latitude: 42.8866177, longitude: -78.8814924);

    final waypoints = <WayPoint>[cityHall, downtown];

    bool isRouteBuilt =
        await _controller?.buildRoute(wayPoints: waypoints) ?? false;
    if (isRouteBuilt) {
      // Route data will be handled in the event listener
      await _controller?.startNavigation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(36.1175275, -115.1839524),
                zoom: 13.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                // Initial map update
              },
              markers: _markers,
              polylines: _polyline != null ? {_polyline!} : {},
            ),
          ),
          Container(
            height: 200,
            color: Colors.grey,
            child: MapBoxNavigationView(
              options: _options,
              onRouteEvent: _onRouteEvent,
              onCreated: (MapBoxNavigationViewController controller) {
                _controller = controller;
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNavigation,
        child: const Icon(Icons.directions),
      ),
    );
  }
}
