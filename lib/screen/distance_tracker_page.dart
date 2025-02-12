import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gis_osm/bloc/auth/auth_event.dart';
import 'package:gis_osm/common/user_storage.dart';
import 'package:gis_osm/screen/sidebar.dart';
import 'package:latlong2/latlong.dart';
import '../data/models/user.dart';
import '../data/models/user_location.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_location_repository.dart';
import '../services/location_service.dart';
import '../bloc/auth/auth_bloc.dart';
import 'auth_screen.dart';

class DistanceTrackerPage extends StatefulWidget {
  const DistanceTrackerPage({Key? key}) : super(key: key);

  @override
  _DistanceTrackerPageState createState() => _DistanceTrackerPageState();
}

class _DistanceTrackerPageState extends State<DistanceTrackerPage> {
  final MapController _mapController = MapController();
  LatLng _currentUserLocation = LatLng(0, 0);
  List<LatLng> _userLocations = [];
  List<String> _userNames = [];
  double? _distance;
  final List<LatLng> _routePoints = [];
  double _rotation = 0.0;
  bool _isExpanded = false;

  final UserLocationRepository _userLocationRepository = UserLocationRepository();
  final AuthRepository _userRepository = AuthRepository();

  // Loading and error states
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _fetchUserLocations();
    _fetchUsers();
  }

  Future<void> _initializeLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      setState(() => _currentUserLocation = location);
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _fetchUserLocations() async {
    try {
      final List<UserLocation> userLocations = await _userLocationRepository.getAllUserLocations();

      final filteredUserLocations = userLocations.where((user) => user.issharinglocation == true).toList();

      setState(() {
        _userLocations = filteredUserLocations.map((user) => LatLng(user.latitude, user.longitude)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user locations: $e';
        print(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final List<User> users = await _userRepository.getAllUsers();
      setState(() {
        _userNames = users.map((user) => user.email).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user names: $e';
        print(e);
        _isLoading = false;
      });
    }
  }


  Future<void> _getCurrentLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      setState(() {
        _currentUserLocation = location;
        _mapController.move(location, 15.0);
      });

      int? userId = await UserStorage.getUserId();

      if(userId != null){
        UserLocation loadUserLocation = await _userLocationRepository.getUserLocationByUserId(userId);

        UserLocation saveUserLocation = UserLocation(
          id: loadUserLocation.id,
          userid: userId,
          latitude: _currentUserLocation.latitude,
          longitude: _currentUserLocation.longitude,
          issharinglocation: false,
        );
        await _userLocationRepository.updateUserLocation(saveUserLocation);
      }
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
          _routePoints.clear();
          _routePoints.addAll(result.routePoints);
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
      _mapController.fitBounds(bounds, options: const FitBoundsOptions(padding: EdgeInsets.all(50)));
    }
  }

  void _resetRotation() {
    setState(() {
      _rotation = 0.0;
      _mapController.rotate(0);
    });
  }

  void _moveToUserLocation(LatLng location) {
    setState(() => _mapController.move(location, 15.0));
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final appBarFontSize = screenWidth * 0.05; // 5% of screen width
    final buttonSize = screenWidth * 0.12; // 12% of screen width
    final paddingValue = screenWidth * 0.05; // 5% of screen width
    final markerSize = screenWidth * 0.08; // 8% of screen width

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Location Tracker',
          style: TextStyle(fontSize: appBarFontSize),
        ),
        actions: [
          FutureBuilder(
            future: UserStorage.getEmail(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
              } else {
                final email = snapshot.data ?? 'Guest';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(email, style: TextStyle(fontSize: appBarFontSize * 0.8, color: Colors.black)),
                );
              }
            },
          ),
        ],
      ),
      drawer: Sidebar(
        onHomeTap: () {
          print("Home tapped");
        },
        onTrackLocationTap: () {
          Navigator.pop(context); // Close the drawer
        },
        onSettingsTap: () {
          print("Settings tapped");
        },
        onLogoutTap: () {
          context.read<AuthBloc>().add(LogoutEvent());
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthScreen()));
        },
      ),
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
                          builder: (ctx) => Icon(Icons.my_location, color: Colors.red, size: markerSize),
                        ),
                        ..._userLocations.map(
                              (location) => Marker(
                            point: location,
                            builder: (ctx) => GestureDetector(
                              onTap: () => _calculateDistance(location),
                              child: Icon(Icons.location_on, color: Colors.blue, size: markerSize),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(points: _routePoints, color: Colors.green, strokeWidth: 4.0),
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
                      Text('Distance: ${_distance!.toStringAsFixed(2)} km', style: TextStyle(fontSize: appBarFontSize * 0.8)),
                    const SizedBox(height: 8),
                    Text('Tap on a blue marker to calculate the distance.', style: TextStyle(color: Colors.grey, fontSize: appBarFontSize * 0.6)),
                  ],
                ),
              ),
            ],
          ),
          // Expand/Collapse Button
          Positioned(
            bottom: screenHeight * 0.1,
            right: screenWidth * 0.05,
            child: FloatingActionButton(
              heroTag: 'togglePanel',
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              backgroundColor: Colors.green,
              child: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white, size: buttonSize * 0.6),
            ),
          ),
          if (_isExpanded)
            Positioned(
              bottom: screenHeight * 0.18,
              right: screenWidth * 0.05,
              child: Container(
                width: screenWidth * 0.3,
                padding: EdgeInsets.all(paddingValue * 0.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: _userLocations.isEmpty
                    ? Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(fontSize: appBarFontSize * 0.7, color: Colors.grey),
                  ),
                )
                    : ListView(
                  shrinkWrap: true,
                  children: _userLocations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final location = entry.value;
                    return ListTile(
                      title: Text(
                        _userNames[index],
                        style: TextStyle(fontSize: appBarFontSize * 0.7),
                      ),
                      onTap: () {
                        _moveToUserLocation(location);
                        setState(() => _isExpanded = false);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          // Current Location Button
          Positioned(
            bottom: screenHeight * 0.05,
            right: screenWidth * 0.05,
            child: FloatingActionButton(
              heroTag: 'currentLocation',
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.blue,
              child: Icon(Icons.my_location, color: Colors.white, size: buttonSize * 0.6),
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, spreadRadius: 1)],
                ),
                child: Transform.rotate(
                  angle: -_rotation * (3.1415926535 / 180),
                  child: Icon(Icons.explore, color: Colors.blue, size: buttonSize * 0.6),
                ),
              ),
            ),
          ),
          // Loading Indicator
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          // Error Message
          if (_errorMessage != null)
            Positioned(
              bottom: screenHeight * 0.5,
              left: screenWidth * 0.1,
              right: screenWidth * 0.1,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}