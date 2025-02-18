import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gis_osm/bloc/auth/auth_event.dart';
import 'package:gis_osm/common/user_storage.dart';
import 'package:gis_osm/screen/sidebar.dart';
import 'package:gis_osm/screen/user_list_screen.dart';
import 'package:latlong2/latlong.dart';
import '../data/models/user.dart';
import '../data/models/user_location.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_location_repository.dart';
import '../services/location_service.dart';
import '../bloc/auth/auth_bloc.dart';
import '../services/user_service.dart';
import '../widgets/app_bar_action_name.dart';
import 'auth_screen.dart';

class DistanceTrackerPage extends StatefulWidget {
  const DistanceTrackerPage({Key? key}) : super(key: key);

  @override
  _DistanceTrackerPageState createState() => _DistanceTrackerPageState();
}

class _DistanceTrackerPageState extends State<DistanceTrackerPage> {
  final UserLocationRepository _userLocationRepository = UserLocationRepository();
  final AuthRepository _userRepository = AuthRepository();
  final UserService _userService = UserService();

  final MapController _mapController = MapController();
  LatLng _currentUserLocation = LatLng(0, 0);
  List<UserLocation> _userLocations = []; // Store UserLocation objects
  List<User> _users = [];
  double? _distance;
  final List<LatLng> _routePoints = [];
  double _rotation = 0.0;
  bool _isExpanded = false;
  User? _user;
  bool isShareLocation = false;
  Timer? _locationUpdateTimer;
  UserLocation? _userLocation;

  // Loading and error states
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _fetchUserLocations();
    _fetchUser();
    _fetchUsers();
  }

  Future _initializeLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      setState(() {
        _currentUserLocation = location;
      });

      _mapController.move(_currentUserLocation, 15.0); // Zoom level 15
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _fetchUser() async {
    try {
      final user = await _userService.fetchUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await _userService.fetchUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }

  Future _getCurrentLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();

      if (mounted) {
        setState(() {
          _currentUserLocation = location;
          _mapController.move(location, 15.0);
        });

        int? userId = await UserStorage.getUserId();
        if (userId != null) {
          _userLocation = await _userLocationRepository.getUserLocationByUserId(userId);
          UserLocation updateUserLocation = UserLocation(
            id: _userLocation?.id,
            userid: userId,
            latitude: _currentUserLocation.latitude,
            longitude: _currentUserLocation.longitude,
            issharinglocation: false,
          );
          await _userLocationRepository.updateUserLocation(updateUserLocation);
        }
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _fetchUserLocations() async {
    try {
      final List<UserLocation> userLocations =
      await _userLocationRepository.getAllUserLocations();

      final filteredUserLocations = userLocations
          .where((user) => user.issharinglocation == true &&
          (user.latitude != _currentUserLocation.latitude ||
              user.longitude != _currentUserLocation.longitude))
          .toList();

      setState(() {
        _userLocations = filteredUserLocations; // Store UserLocation objects
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

  Future<void> _calculateDistance(LatLng targetLocation) async {
    try {
      final result = await LocationService.getRouteDistance(
          _currentUserLocation, targetLocation);
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

  void _resetRotation() {
    setState(() {
      _rotation = 0.0;
      _mapController.rotate(0);
    });
  }

  void _fitMapToRoute() {
    if (_routePoints.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(_routePoints);

      final centerLatLng = LatLng(
        (bounds.north + bounds.south) / 2,
        (bounds.east + bounds.west) / 2,
      );

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      // Calculate the zoom level manually
      final double worldSize = 256; // Base tile size in pixels
      final double maxZoom = 20.0; // Maximum zoom level supported by the map

      // Calculate the span of the bounds in degrees
      final double latSpan = bounds.north - bounds.south;
      final double lngSpan = bounds.east - bounds.west;

      // Calculate the zoom level for latitude and longitude
      final double latZoom = log(screenHeight * 360 / (latSpan * worldSize)) / log(2);
      final double lngZoom = log(screenWidth * 360 / (lngSpan * worldSize)) / log(2);

      // Use the smaller zoom level to ensure the entire bounds fit
      final double zoom = latZoom < lngZoom ? latZoom : lngZoom;

      // Ensure the zoom level is within valid bounds
      final double clampedZoom = zoom.clamp(0, maxZoom);

      // Move the map to the calculated center and zoom level
      _mapController.move(centerLatLng, clampedZoom);
    }
  }

  void _moveToUserLocation(LatLng location) {
    setState(() => _mapController.move(location, 15.0));
  }

  void _toggleLocationSharing(bool value) {
    setState(() {
      isShareLocation = value;
    });

    if (isShareLocation) {
      _startLocationUpdates();
    } else {
      _stopLocationUpdates();
    }
  }

  // Start periodic location updates
  void _startLocationUpdates() {
    _locationUpdateTimer?.cancel(); // Ensure no duplicate timers
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!mounted) return; // Ensure widget is still in the tree
      try {
        final newLocation = await LocationService.getCurrentLocation();
        if (mounted) {
          setState(() {
            _currentUserLocation = newLocation;
          });

          UserLocation updateUserLocation = UserLocation(
            id: _userLocation?.id,
            userid: _userLocation!.userid,
            latitude: _currentUserLocation.latitude,
            longitude: _currentUserLocation.longitude,
            issharinglocation: true,
          );
          await _userLocationRepository.updateUserLocation(updateUserLocation);
        }
      } catch (e) {
        print("Error updating location: $e");
      }
    });
  }

  void _stopLocationUpdates() {
    _locationUpdateTimer?.cancel(); // Stop the timer properly
    _locationUpdateTimer = null;
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel(); // Prevent further execution
    _locationUpdateTimer = null;
    super.dispose();
  }

  static const WidgetStateProperty<Icon> thumbIcon =
  WidgetStateProperty<Icon>.fromMap(
    <WidgetStatesConstraint, Icon>{
      WidgetState.selected: Icon(Icons.check),
      WidgetState.any: Icon(Icons.close),
    },
  );

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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: appBarFontSize,
          ),
        ),
        actions: [
          AppBarActionName(fontSize: appBarFontSize * 0.8),
        ],
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Sidebar(
        onHomeTap: () {
          print("Home tapped");
        },
        onUsersTap: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => UserListScreen()));
        },
        onTrackLocationTap: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => DistanceTrackerPage()));
        },
        onSettingsTap: () {
          print("Settings tapped");
        },
        onLogoutTap: () {
          context.read<AuthBloc>().add(LogoutEvent());
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => AuthScreen()));
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
                    initialCenter: _currentUserLocation,
                    minZoom: 10.0,
                    initialRotation: _rotation,
                    onTap: (_, __) {
                      setState(() {
                        _routePoints.clear();
                        _distance = null;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.location_tracker',
                    ),
                    MarkerLayer(
                      markers: [
                        // Blue markers for other users
                        ..._userLocations.map(
                              (userLocation) {
                            final user = _users.firstWhere(
                                  (u) => u.id == userLocation.userid,
                              orElse: () => User(
                                id: 0,
                                firstname: "Unknown",
                                email: "",
                                password: "", fullname: '', lastname: ''
                              ),
                            );
                            return Marker(
                              point: LatLng(userLocation.latitude, userLocation.longitude),
                              width: markerSize * 2,
                              height: markerSize * 2,
                              child: GestureDetector(
                                onTap: () => _calculateDistance(
                                    LatLng(userLocation.latitude, userLocation.longitude)),
                                child: Column(
                                  children: [
                                    Text(
                                      user.firstname, // Display user's name
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        backgroundColor: Colors.black54,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/person_marker.png', // Ensure this file exists in assets
                                          width: markerSize * 0.8,
                                          height: markerSize * 0.8,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // Red marker for the current user
                        Marker(
                          point: _currentUserLocation,
                          width: markerSize * 2,
                          height: markerSize * 2,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => print("Current location tapped!"),
                            child: Icon(Icons.my_location, color: Colors.red, size: markerSize),
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
                              strokeWidth: 4.0),
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
                      Text('Distance: ${_distance!.toStringAsFixed(2)} km',
                          style: TextStyle(fontSize: appBarFontSize * 0.8)),
                    const SizedBox(height: 8),
                    Text('Tap on a blue marker to calculate the distance.',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: appBarFontSize * 0.6)),
                  ],
                ),
              ),
            ],
          ),
          // Current Location Button
          Positioned(
            bottom: screenHeight * 0.05,
            right: screenWidth * 0.05,
            child: FloatingActionButton(
              heroTag: 'currentLocation',
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.blue,
              child: Icon(Icons.my_location,
                  color: Colors.white, size: buttonSize * 0.6),
            ),
          ),
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
                  child: Icon(
                    Icons.explore,
                    color: Colors.blue,
                    size: buttonSize * 0.6,
                  ),
                ),
              ),
            ),
          ),

          // Add the Switch widget here
          Positioned(
            top: screenHeight * 0.1 + buttonSize + 10,
            // Adjust position below the reset button
            right: screenWidth * 0.05,
            child: Switch(
              thumbIcon: thumbIcon,
              value: isShareLocation,
              onChanged: _toggleLocationSharing,
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