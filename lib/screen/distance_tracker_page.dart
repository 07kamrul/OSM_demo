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
  List<String> _userNames = ["User 1", "User 2", "User 3"];
  double? _distance;
  List<LatLng> _routePoints = [];
  double _rotation = 0.0;
  bool _isExpanded = false;

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
    try {
      final result = await LocationService.getRouteDistance(_currentUserLocation, targetLocation);
      if (result != null && result.distance != null) {
        setState(() {
          _distance = result.distance;
          _routePoints = result.routePoints;
        });
        _fitMapToRoute();
      } else {
        print("No valid route data received: $result");
      }
    } catch (e) {
      print("Error fetching road distance: $e");
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

  void _moveToUserLocation(LatLng location) {
    setState(() {
      _mapController.move(location, 15.0);
    });
  }

  void _zoomIn() {
    setState(() {
      _mapController.move(_mapController.center, _mapController.zoom + 1);
    });
  }

  void _zoomOut() {
    setState(() {
      _mapController.move(_mapController.center, _mapController.zoom - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Use relative positioning and sizes based on screen size
    double buttonSize = screenWidth * 0.12; // Adjust button size relative to screen width
    double paddingValue = screenWidth * 0.05; // Padding relative to screen width

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
                padding: EdgeInsets.all(paddingValue),
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
          // Zoom In Button
          Positioned(
            bottom: screenHeight * 0.2, // Adjust based on screen height
            right: screenWidth * 0.05,
            child: FloatingActionButton(
              onPressed: _zoomIn,
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
          // Zoom Out Button
          Positioned(
            bottom: screenHeight * 0.13, // Adjust based on screen height
            right: screenWidth * 0.05,
            child: FloatingActionButton(
              onPressed: _zoomOut,
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.remove, color: Colors.black),
            ),
          ),
          // Expand/Collapse Button
          Positioned(
            bottom: screenHeight * 0.1,
            right: screenWidth * 0.05,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              backgroundColor: Colors.green,
              child: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white),
            ),
          ),
          if (_isExpanded)
            Positioned(
              bottom: screenHeight * 0.18,
              right: screenWidth * 0.05,
              child: Container(
                width: screenWidth * 0.5, // Use screen width for responsiveness
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: List.generate(_userLocations.length, (index) {
                    return ListTile(
                      title: Text(_userNames[index]),
                      onTap: () {
                        _moveToUserLocation(_userLocations[index]);
                        setState(() {
                          _isExpanded = false;
                        });
                      },
                    );
                  }),
                ),
              ),
            ),
          // Current Location Button
          Positioned(
            bottom: screenHeight * 0.05,
            right: screenWidth * 0.05,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          // Reset Rotation Button
          Positioned(
            top: screenHeight * 0.1,
            right: screenWidth * 0.05,
            child: GestureDetector(
              onTap: _resetRotation,
              child: Container(
                width: buttonSize,
                height: buttonSize,
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
