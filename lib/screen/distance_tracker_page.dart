import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gis_osm/bloc/auth/auth_event.dart';
import 'package:gis_osm/common/user_storage.dart';
import 'package:gis_osm/screen/chat_screen.dart';
import 'package:gis_osm/screen/profile_screen.dart';
import 'package:gis_osm/screen/sidebar.dart';
import 'package:gis_osm/screen/user_list_screen.dart';
import 'package:latlong2/latlong.dart';
import '../data/models/user.dart';
import '../data/models/user_location.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_location_repository.dart';
import '../enum.dart';
import '../services/location_service.dart';
import '../bloc/auth/auth_bloc.dart';
import '../services/user_service.dart';
import '../widgets/app_bar_action_name.dart';
import 'auth_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DistanceTrackerPage extends StatefulWidget {
  const DistanceTrackerPage({super.key});

  @override
  State<DistanceTrackerPage> createState() => _DistanceTrackerPageState();
}

class _DistanceTrackerPageState extends State<DistanceTrackerPage> {
  // Use late initialization where appropriate
  late final UserLocationRepository _userLocationRepository =
      UserLocationRepository();
  late final AuthRepository _userRepository = AuthRepository();
  late final UserService _userService = UserService();
  late final MapController _mapController = MapController();

  // Group related variables
  LatLng _currentUserLocation = const LatLng(0, 0);
  final List<UserLocation> _userLocations = [];
  final List<User> _users = [];
  final List<LatLng> _routePoints = [];

  // UI states
  double _distance = 0.0;
  double _rotation = 0.0;
  bool _isLoading = true;
  double _maxDistance = 0.5; // Default 500 meters

  String? _errorMessage;

  User? _user;
  UserLocation? _userLocation;
  Timer? _locationUpdateTimer;

  bool _isShareLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _fetchUser(),
      _fetchUsers(),
      _initializeLocation(),
      _fetchUserLocations(),
    ]);
    _startPeriodicUpdates();
  }

  Future<void> _initializeLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentUserLocation = location;
          _isLoading = false;
        });
        _mapController.move(location, AppConstants.defaultZoom);
      }
    } catch (e) {
      _handleError('Error initializing location: $e');
    }
  }

  Future<void> _fetchUser() async {
    try {
      _user = await _userService.fetchUser();
    } catch (e) {
      _handleError('Failed to load user: $e');
    }
  }

  Future<void> _fetchUsers() async {
    try {
      _users.addAll(await _userService.fetchUsers());
    } catch (e) {
      _handleError('Failed to load users: $e');
    }
  }

  Future<void> _fetchUserLocations() async {
    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        throw 'User ID not found';
      } else {
        await _updateUserLocation(userId);
      }

      final userLocations = await _userLocationRepository.getAllUserLocations();

      setState(() {
        _userLocations.clear();
        _userLocations.addAll(userLocations.where((user) =>
            user.issharinglocation == true &&
            user.userid != userId &&
            (user.latitude != _currentUserLocation.latitude ||
                user.longitude != _currentUserLocation.longitude)));
        _isLoading = false;

        _isShareLocation = userLocations
            .firstWhere((u) => u.userid == userId,
                orElse: () => UserLocation(
                    id: 0,
                    userid: 0,
                    latitude: 0,
                    longitude: 0,
                    issharinglocation: false))
            .issharinglocation;
      });

      _mapController.move(_currentUserLocation, AppConstants.defaultZoom);
    } catch (e) {
      _handleError('Failed to load user locations: ${e.toString()}');
    }
  }

  int? _selectedUserId;

  Future<void> _calculateDistance(int userId, LatLng target) async {
    try {
      final result =
          await LocationService.getRouteDistance(_currentUserLocation, target);
      if (result?.distance != null) {
        setState(() {
          _distance = result!.distance!;
          _routePoints.clear();
          _routePoints.addAll(result.routePoints);
          _selectedUserId = userId;
        });
        _fitMapToRoute();
      }
    } catch (e) {
      debugPrint('Error calculating distance: $e');
    }
  }

  Future<void> _updateUserLocation(int userId) async {
    if (_userLocation != null) {
      final updatedLocation = UserLocation(
        id: _userLocation!.id,
        userid: userId,
        latitude: _currentUserLocation.latitude,
        longitude: _currentUserLocation.longitude,
        issharinglocation: _isShareLocation,
      );
      await _userLocationRepository.updateUserLocation(updatedLocation);
    }
  }

  void _fitMapToRoute() {
    if (_routePoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(_routePoints);
    _mapController.fitCamera(CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.all(50),
    ));
  }

  void _resetRotation() {
    setState(() {
      _rotation = 0.0;
      _mapController.rotate(0);
    });
  }

  void _toggleLocationSharing(bool value) {
    setState(() => _isShareLocation = value);
    value ? _startPeriodicUpdates() : _stopPeriodicUpdates();
    _updateUserLocationSharing();
  }

  // Add this new method
  Future<void> _updateUserLocationSharing() async {
    try {
      if (_userLocation != null) {
        final updatedLocation = UserLocation(
          id: _userLocation!.id,
          userid: _userLocation!.userid,
          latitude: _currentUserLocation.latitude,
          longitude: _currentUserLocation.longitude,
          issharinglocation: _isShareLocation,
        );
        await _userLocationRepository.updateUserLocation(updatedLocation);
      }
    } catch (e) {
      _handleError('Error updating location sharing status: $e');
    }
  }

  void _startPeriodicUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer =
        Timer.periodic(AppConstants.locationUpdateInterval, (_) async {
      if (!mounted) return;
      await _updateLocation(false);
    });
  }

  Future<void> _updateLocation(bool isClick) async {
    try {
      final location = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() => _currentUserLocation = location);
        final userId = await UserStorage.getUserId();
        if (userId != null) await _updateUserLocation(userId);
        if (isClick) {
          _mapController.move(_currentUserLocation, AppConstants.defaultZoom);
        }
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  void _stopPeriodicUpdates() => _locationUpdateTimer?.cancel();

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
    debugPrint(message);
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.05;
    final appBarFontSize = size.width * AppConstants.appBarFontScale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Location Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: size.width * 0.05,
          ),
        ),
        actions: [
          AppBarActionName(
            fontSize: appBarFontSize * 0.8,
          )
        ],
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentUserLocation,
                    minZoom: AppConstants.minZoom,
                    initialRotation: _rotation,
                    onTap: (_, __) {
                      setState(() {
                        _routePoints.clear(); // Clear existing polyline points
                        _distance = 0.0;
                      });
                    },
                  ),
                  children: [
                    TileLayer(urlTemplate: AppConstants.tileUrl),
                    MarkerLayer(markers: _buildMarkers(size)),
                    if (_routePoints
                        .isNotEmpty) // Only show polyline if it has points
                      PolylineLayer(polylines: [
                        Polyline(
                          points: _routePoints,
                          color: Colors.green,
                          strokeWidth: 4.0,
                        ),
                      ]),
                  ],
                ),
              ),
              if (_routePoints.isNotEmpty) _buildDistanceInfo(padding, size),
            ],
          ),
          _buildFloatingButtons(size),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null) _buildErrorMessage(size, _errorMessage!),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Sidebar(
      onHomeTap: () => Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DistanceTrackerPage())),
      onUsersTap: () => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const UserListScreen())),
      onTrackLocationTap: () => Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DistanceTrackerPage())),
      // onChatBoxTap: () => Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //         builder: (_) => ChatScreen(senderId: 1, receiverId: 1))),
      onSettingsTap: () => debugPrint("Settings tapped"),
      onLogoutTap: () {
        context.read<AuthBloc>().add(LogoutEvent());
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AuthScreen()));
      },
    );
  }

  List<Marker> _buildMarkers(Size size) {
    final markerSize = size.width * 0.08;
    final markers = _userLocations.map((loc) {
      final user = _users.firstWhere((u) => u.id == loc.userid,
          orElse: () => User(
              id: 0,
              firstname: "Unknown",
              email: "",
              password: "",
              fullname: '',
              lastname: ''));
      return Marker(
        point: LatLng(loc.latitude, loc.longitude),
        width: markerSize * 2,
        height: markerSize * 2.5,
        child: GestureDetector(
          onTap: () => _calculateDistance(
              loc.userid, LatLng(loc.latitude, loc.longitude)),
          child: _buildMarkerContent(user.firstname, markerSize),
        ),
      );
    }).toList();

    markers.add(Marker(
      point: _currentUserLocation,
      width: markerSize * 2,
      height: markerSize * 2.5,
      child: _buildMarkerContent("Me", markerSize),
    ));

    return markers;
  }

  Widget _buildMarkerContent(String label, double markerSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 4, vertical: 1), // Reduce vertical padding
          margin: EdgeInsets.zero, // Remove extra spacing
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              )),
        ),
        ClipOval(
          child: Image.asset(
            'assets/person_marker.png',
            width: markerSize * 1.8,
            height: markerSize * 1.8,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceInfo(double padding, Size size) {
    final isSmallScreen = size.width < AppConstants.smallScreenBreakpoint;
    final isLargeScreen = size.width >= AppConstants.largeScreenBreakpoint;
    final isTablet = size.width >= AppConstants.largeScreenBreakpoint &&
        size.width < AppConstants.extraLargeScreenBreakpoint;

    // Dynamic Sizing
    final double buttonSize = isSmallScreen
        ? 40.0
        : isTablet
            ? 50.0
            : 56.0;
    final double spacing = size.height * (isSmallScreen ? 0.015 : 0.02);
    final double iconSize = buttonSize * (isSmallScreen ? 0.5 : 0.6);
    final double paddingValue = size.width *
        (isSmallScreen
            ? 0.02
            : isLargeScreen
                ? 0.04
                : 0.03);

    return Padding(
      padding: EdgeInsets.all(paddingValue),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Avatar with Navigation
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    user: _users.firstWhere((u) => u.id == _selectedUserId),
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: isSmallScreen ? 22 : 25,
              backgroundImage: AssetImage(
                  'assets/person_marker.png'), // Change to actual image
            ),
          ),

          SizedBox(width: 10),

          // User Info + Last Active
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _users.firstWhere((u) => u.id == _selectedUserId).fullname ??
                      'Unknown',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Last active 25m ago', // Replace with actual data
                  style: TextStyle(
                      color: Colors.grey, fontSize: isSmallScreen ? 12 : 14),
                ),
              ],
            ),
          ),

          // Chat Button & Distance Info
          Row(
            children: [
              // Chat Button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        senderId: 1,
                        receiverId: 1,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.chat_rounded,
                  size: iconSize,
                  color: isLargeScreen ? Colors.blue : Colors.black,
                ),
              ),
              SizedBox(width: 6),

              // Distance Info
              if (_distance > 0 && _selectedUserId != null)
                Row(
                  children: [
                    Icon(FontAwesomeIcons.car, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Text(
                      '${_distance.toStringAsFixed(2)} km',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons(Size size) {
    // Responsive scaling factors
    final isSmallScreen = size.width < AppConstants.smallScreenBreakpoint;
    final isLargeScreen = size.width >= AppConstants.largeScreenBreakpoint;
    final isTablet = size.width >= AppConstants.largeScreenBreakpoint &&
        size.width < AppConstants.extraLargeScreenBreakpoint;

    // Dynamic sizing based on screen dimensions
    final buttonSize = isSmallScreen
        ? 40.0
        : isTablet
            ? 52.0
            : 56.0;
    final spacing = size.height * (isSmallScreen ? 0.015 : 0.02);
    final padding = size.width *
        (isSmallScreen
            ? 0.02
            : isLargeScreen
                ? 0.04
                : 0.03);
    final iconSize = buttonSize * (isSmallScreen ? 0.5 : 0.6);
    final bottomMargin = size.height * (isSmallScreen ? 0.02 : 0.03);

    return Positioned(
      bottom: bottomMargin, // Changed from top to bottom
      right: padding,
      child: Container(
        padding: EdgeInsets.all(padding * 0.5),
        decoration: isLargeScreen
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius:
                    BorderRadius.circular(8.0), // Optional: Rounded corners
                border: Border.all(
                    color:
                        Colors.transparent), // Optional: Border for visibility
              ),
              padding: EdgeInsets.symmetric(horizontal: 2.0),
              child: DropdownButton<double>(
                value: _maxDistance,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _maxDistance = value;
                    });
                    _fetchUserLocations(); // Refresh data based on new distance
                  }
                },
                items: [0.1, 0.5, 1.0, 2.0, 5.0].map((double value) {
                  return DropdownMenuItem<double>(
                    value: value,
                    child: Text("${(value * 1000).toInt()}M"),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: spacing),
            FloatingActionButton(
              onPressed: _fetchUserLocations,
              mini: isSmallScreen,
              heroTag: 'refresh',
              elevation: isLargeScreen ? 0 : 6,
              backgroundColor: isLargeScreen ? Colors.transparent : null,
              child: Icon(
                Icons.refresh,
                size: iconSize,
                color: isLargeScreen ? Colors.blue : Colors.black,
              ),
            ),
            SizedBox(height: spacing),
            Transform.scale(
              scale: isSmallScreen
                  ? 0.8
                  : isTablet
                      ? 1.1
                      : 1.0,
              child: Switch(
                value: _isShareLocation,
                onChanged: _toggleLocationSharing,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            SizedBox(height: spacing),
            FloatingActionButton(
              onPressed: _resetRotation,
              mini: isSmallScreen,
              heroTag: 'resetRotation',
              elevation: isLargeScreen ? 0 : 6,
              backgroundColor: isLargeScreen ? Colors.transparent : null,
              child: Icon(
                Icons.explore,
                size: iconSize,
                color: isLargeScreen ? Colors.blue : Colors.black,
              ),
            ),
            SizedBox(height: spacing),
            FloatingActionButton(
              onPressed: () =>
                  _updateLocation(true), // Wrap it in a lambda function
              mini: isSmallScreen,
              heroTag: 'updateLocation',
              elevation: isLargeScreen ? 0 : 6,
              backgroundColor: isLargeScreen ? Colors.transparent : null,
              child: Icon(
                Icons.my_location,
                size: iconSize,
                color: isLargeScreen ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(Size size, String message) {
    return Center(
      child: Container(
        width: size.width * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
