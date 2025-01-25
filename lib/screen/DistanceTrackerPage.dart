import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DistanceTrackerPage extends StatefulWidget {
  const DistanceTrackerPage({Key? key}) : super(key: key);

  @override
  _DistanceTrackerPageState createState() => _DistanceTrackerPageState();
}

class _DistanceTrackerPageState extends State<DistanceTrackerPage> {
  final MapController _mapController = MapController();
  LatLng _currentUserLocation = LatLng(35.654231839290084, 140.04207391850457);
  List<LatLng> _userLocations = [
    LatLng(35.550463294248544, 139.77705935405905), // User 2
    LatLng(35.689487, 139.691711), // User 3
    LatLng(35.710063, 139.8107), // User 4
  ];
  double? _distance;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _calculateDistance(LatLng targetLocation) async {
    final String url =
        'https://router.project-osrm.org/route/v1/driving/${_currentUserLocation.longitude},${_currentUserLocation.latitude};${targetLocation.longitude},${targetLocation.latitude}?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final distanceMeters = data['routes'][0]['distance'];
        final coordinates = data['routes'][0]['geometry']['coordinates'];

        setState(() {
          _distance = distanceMeters / 1000; // Convert to kilometers
          _routePoints = coordinates
              .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
              .toList();
        });

        _fitMapToRoute();
      } else {
        throw Exception('Failed to fetch road distance.');
      }
    } catch (e) {
      print('Error fetching road distance: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentUserLocation,
                zoom: 10.0,
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
                        Icons.location_on,
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
    );
  }
}
