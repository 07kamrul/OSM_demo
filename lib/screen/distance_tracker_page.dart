import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../service/location_service.dart';

class DistanceTrackerPage extends StatefulWidget {
  const DistanceTrackerPage({Key? key}) : super(key: key);

  @override
  _DistanceTrackerPageState createState() => _DistanceTrackerPageState();
}

class _DistanceTrackerPageState extends State<DistanceTrackerPage> {
  final MapController _mapController = MapController();
  LatLng _currentUserLocation = LatLng(0, 0);
  List<LatLng> _userLocations = [
    LatLng(35.550463294248544, 139.77705935405905),
    LatLng(35.689487, 139.691711),
    LatLng(35.710063, 139.8107),
  ];
  double? _distance;
  List<LatLng> _routePoints = [];
  double _rotation = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      _currentUserLocation = await LocationService.getCurrentLocation();
      setState(() {});
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LatLng location = await LocationService.getCurrentLocation();
      setState(() {
        _currentUserLocation = location;
        _mapController.move(location, 15.0);
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _calculateDistance(LatLng targetLocation) async {
    final result = await LocationService.getRouteDistance(_currentUserLocation, targetLocation);
    if (result != null) {
      setState(() {
        _distance = result.distance;
        _routePoints = result.routePoints;
      });
      _fitMapToRoute();
    }
  }

  void _fitMapToRoute() {
    if (_routePoints.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(_routePoints);
      _mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
      );
    }
  }

  void _resetRotation() {
    setState(() {
      _rotation = 0.0;
      _mapController.rotate(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Tracker')),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentUserLocation,
                    zoom: 10.0,
                    rotation: _rotation,
                    onTap: (_, __) {
                      setState(() {
                        _routePoints.clear();
                        _distance = null;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.location_tracker',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentUserLocation,
                          builder: (ctx) => const Icon(
                            Icons.my_location,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        ..._userLocations.map(
                              (location) => Marker(
                            point: location,
                            builder: (ctx) => GestureDetector(
                              onTap: () => _calculateDistance(location),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.green,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_distance != null)
                      Text(
                        'Distance: ${_distance!.toStringAsFixed(2)} km',
                        style: const TextStyle(fontSize: 18),
                      ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap on a blue marker to calculate the distance.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          Positioned(
            top: 80,
            right: 15,
            child: GestureDetector(
              onTap: _resetRotation,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: -_rotation * (3.1415926535 / 180),
                  child: const Icon(Icons.explore, color: Colors.blue, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}