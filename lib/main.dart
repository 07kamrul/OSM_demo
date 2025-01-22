import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const OSMDistanceApp());
}

class OSMDistanceApp extends StatelessWidget {
  const OSMDistanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OSM Road Distance Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DistanceTrackerPage(),
    );
  }
}

class DistanceTrackerPage extends StatefulWidget {
  const DistanceTrackerPage({Key? key}) : super(key: key);

  @override
  _DistanceTrackerPageState createState() => _DistanceTrackerPageState();
}

class _DistanceTrackerPageState extends State<DistanceTrackerPage> {
  final MapController _mapController = MapController();
  LatLng _user1Location = LatLng(35.654231839290084, 140.04207391850457);
  LatLng _user2Location = LatLng(35.550463294248544, 139.77705935405905);
  double? _distance;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _getRoadDistance();
  }

  Future<void> _getRoadDistance() async {
    final String url =
        'https://router.project-osrm.org/route/v1/driving/${_user1Location.longitude},${_user1Location.latitude};${_user2Location.longitude},${_user2Location.latitude}?overview=full&geometries=geojson';

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OSM Road Distance Tracker'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait = constraints.maxWidth < constraints.maxHeight;

          return Flex(
            direction: isPortrait ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                flex: 3,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _user1Location,
                    zoom: 4.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.osm_distance_tracker',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _user1Location,
                          builder: (ctx) => const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        Marker(
                          point: _user2Location,
                          builder: (ctx) => const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40,
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
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_distance != null)
                        Text(
                          'Road Distance: ${_distance!.toStringAsFixed(2)} km',
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        'Red Marker: User 1\nBlue Marker: User 2',
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
