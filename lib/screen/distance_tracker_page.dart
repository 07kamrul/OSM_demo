import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gis_osm/enum.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../common/user_storage.dart';
import '../data/models/match_users.dart';
import '../data/models/user.dart';
import '../data/models/user_location.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/match_user_repository.dart';
import '../data/repositories/user_location_repository.dart';
import '../screen/auth_screen.dart';
import '../screen/chat_screen.dart';
import '../screen/profile_screen.dart';
import '../screen/sidebar.dart';
import '../screen/user_list_screen.dart';
import '../services/location_service.dart';
import '../services/user_service.dart';
import '../widgets/app_bar_action_name.dart';
import 'chat_box_screen.dart';

class DistanceTrackerPage extends StatefulWidget {
  const DistanceTrackerPage({super.key});

  @override
  State<DistanceTrackerPage> createState() => _DistanceTrackerPageState();
}

class _DistanceTrackerPageState extends State<DistanceTrackerPage> {
  late final UserLocationRepository _userLocationRepository =
      UserLocationRepository();
  late final AuthRepository _userRepository = AuthRepository();
  late final MatchUsersRepository _matchUsersRepository =
      MatchUsersRepository();
  late final UserService _userService = UserService();
  late final MapController _mapController = MapController();

  LatLng? _previousLocation;
  LatLng _currentUserLocation = const LatLng(0, 0);
  late List<UserLocation> _userLocations = [];
  late List<User> _users = [];
  final List<LatLng> _routePoints = [];
  late List<MatchUsers> _matchUsers = [];
  double _startDistance = 0.0;
  double _distance = 0.0;
  double _rotation = 0.0;
  bool _isLoading = true;
  double _maxDistance = 0.5;
  String? _errorMessage;
  User? _user;
  UserLocation? _userLocation;
  Timer? _locationUpdateTimer;
  bool _isShareLocation = false;
  int? _selectedUserId;
  double? _currentZoom; // Track the current zoom level

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        _fetchUser(),
        _updateStartLocation(),
        _initializeLocation(),
        _fetchUsers(),
        _fetchMatchUsers(),
      ]);
      _startPeriodicUpdates();
    } catch (e) {
      _handleError('Initialization failed: $e');
    }
  }

  Future<void> _initializeLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentUserLocation = location;
          _isLoading = false;
          _currentZoom = AppConstants.defaultZoom; // Initial zoom
        });

        if (_userLocation != null) await _updateStartLocation();

        if (_previousLocation == null ||
            _previousLocation != _currentUserLocation) {
          _mapController.move(_currentUserLocation, _currentZoom!);
          _previousLocation = _currentUserLocation;
        }
      }
    } catch (e) {
      _handleError('Error initializing location: $e');
    }
  }

  Future<void> _fetchUser() async {
    try {
      final userId = await UserStorage.getUserId();
      if (userId != null) {
        final userFuture = _userService.fetchUser();
        final userLocationFuture =
            _userLocationRepository.getUserLocationByUserId(userId);

        _user = await userFuture;
        _userLocation = await userLocationFuture;

        _previousLocation =
            LatLng(_userLocation!.startlatitude, _userLocation!.startlongitude);
        _isShareLocation = _userLocation?.issharinglocation ?? false;
      } else {
        throw 'User ID not found';
      }
    } catch (e) {
      _handleError('Failed to load user: $e', e);
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await _userService.fetchUsers();
      if (mounted) {
        setState(() => _users = users);
      }
    } catch (e) {
      _handleError('Failed to load users: $e', e);
    }
  }

  Future<void> _fetchMatchUsers() async {
    try {
      final userId = _user?.id ?? await UserStorage.getUserId();
      if (userId != null) {
        final matchUsers = await _matchUsersRepository.getMatchUsers(userId);
        if (mounted) {
          setState(() {
            _matchUsers = matchUsers;
            _userLocations =
                matchUsers.map((matchUser) => matchUser.location).toList();
            _isLoading = false;
          });

          if (_previousLocation == null ||
              _previousLocation != _currentUserLocation) {
            _mapController.move(
                _currentUserLocation, _currentZoom ?? AppConstants.defaultZoom);
            _previousLocation = _currentUserLocation;
          }
        }
      } else {
        throw 'User ID not found';
      }
    } catch (e) {
      _handleError('Failed to load user locations: $e', e);
    }
  }

  Future<void> _calculateDistance(int userId, LatLng target) async {
    try {
      final result =
          await LocationService.getRouteDistance(_currentUserLocation, target);
      if (result?.distance != null && mounted) {
        setState(() {
          _distance = result!.distance!;
          _routePoints.clear();
          _routePoints.addAll(result.routePoints);
          _selectedUserId = userId;
        });
        _fitMapToRoute(); // Zoom to fit polyline only when explicitly tapped
      }

      if (_userLocation != null) {
        final result = await LocationService.getRouteDistance(
            LatLng(_userLocation!.startlatitude, _userLocation!.startlongitude),
            _currentUserLocation);

        double distanceInMeters = result!.distance * 1000;
        if (distanceInMeters >= 10) _updateLocation();
      }
    } catch (e) {
      debugPrint('Error calculating distance: $e');
    }
  }

  Future<void> _updateStartLocation() async {
    try {
      final updatedLocation = UserLocation(
        id: _userLocation!.id,
        userid: _userLocation!.userid,
        startlatitude: _currentUserLocation.latitude,
        startlongitude: _currentUserLocation.longitude,
        endlatitude: _currentUserLocation.latitude,
        endlongitude: _currentUserLocation.longitude,
        issharinglocation: _isShareLocation,
      );
      await _userLocationRepository.updateUserLocation(updatedLocation);
      if (mounted) setState(() => _userLocation = updatedLocation);
    } catch (e) {
      debugPrint('Error updating user location: $e');
    }
  }

  void _fitMapToRoute() {
    if (_routePoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(_routePoints);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
    _currentZoom =
        _mapController.camera.zoom; // Update current zoom after fitting
  }

  void _resetRotation() {
    if (mounted) {
      setState(() {
        _rotation = 0.0;
        _mapController.rotate(0);
      });
    }
  }

  void _toggleLocationSharing(bool value) {
    if (mounted) {
      setState(() => _isShareLocation = value);
      value ? _startPeriodicUpdates() : _stopPeriodicUpdates();
      _updateUserLocationSharing();
    }
  }

  Future<void> _updateUserLocationSharing() async {
    try {
      if (_userLocation != null) {
        final userId = await UserStorage.getUserId();
        if (userId != null) {
          final updatedLocation = UserLocation(
            id: _userLocation!.id,
            userid: userId,
            startlatitude: _userLocation!.startlatitude,
            startlongitude: _userLocation!.startlongitude,
            endlatitude: _currentUserLocation.latitude,
            endlongitude: _currentUserLocation.longitude,
            issharinglocation: _isShareLocation,
          );
          await _userLocationRepository.updateUserLocation(updatedLocation);
          if (mounted) setState(() => _userLocation = updatedLocation);
        }
      }
    } catch (e) {
      _handleError('Error updating location sharing status: $e');
    }
  }

  void _startPeriodicUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer =
        Timer.periodic(AppConstants.locationUpdateInterval, (_) async {
      if (mounted) await _updateLocation();
    });
  }

  Future<void> _updateLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      if (_previousLocation == null || _previousLocation != location) {
        _updateCurrentLocation(location);
        _previousLocation = location;
      }
      final userId = await UserStorage.getUserId();

      if (userId != null && _isShareLocation) {
        await _updateUserLocation(_userLocation);
      }

      if (_selectedUserId != null) {
        await _recalculateDistanceForSelectedUser();
      }

      await _fetchMatchUsers();
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  void _updateCurrentLocation(LatLng location) {
    if (mounted) {
      setState(() {
        _currentUserLocation = location;
        // Only move the map if no polyline is selected, otherwise keep the current zoom
        if (_routePoints.isEmpty &&
            (_previousLocation == null ||
                _previousLocation != _currentUserLocation)) {
          _mapController.move(
              location, _currentZoom ?? AppConstants.defaultZoom);
          _currentZoom = _mapController.camera.zoom;
        }
      });
    }
  }

  Future<void> _updateUserLocation(UserLocation? userLocation) async {
    if (userLocation == null) return;

    final result = await LocationService.getRouteDistance(
        LatLng(userLocation.startlatitude, userLocation.startlongitude),
        _currentUserLocation);

    double distanceInMeters = result!.distance * 1000;

    if (distanceInMeters >= 10) {
      final updatedLocation = UserLocation(
        id: userLocation.id,
        userid: userLocation.userid,
        startlatitude: _currentUserLocation.latitude,
        startlongitude: _currentUserLocation.longitude,
        endlatitude: _currentUserLocation.latitude,
        endlongitude: _currentUserLocation.longitude,
        issharinglocation: _isShareLocation,
      );

      await _userLocationRepository.updateUserLocation(updatedLocation);
      if (mounted) setState(() => _userLocation = updatedLocation);
    }
  }

  Future<void> _recalculateDistanceForSelectedUser() async {
    final selectedUserLocation = _userLocations.firstWhere(
      (loc) => loc.userid == _selectedUserId,
      orElse: () => UserLocation(
        id: 0,
        userid: 0,
        startlatitude: 0,
        startlongitude: 0,
        endlatitude: 0,
        endlongitude: 0,
        issharinglocation: false,
      ),
    );

    await _calculateDistance(
      _selectedUserId!,
      LatLng(
          selectedUserLocation.endlatitude, selectedUserLocation.endlongitude),
    );
  }

  void _stopPeriodicUpdates() => _locationUpdateTimer?.cancel();

  void _handleError(String message, [dynamic error]) {
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

    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildMap()),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.width * 0.04;

    return AppBar(
      title: Text(
        'Location Tracker',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
      ),
      actions: [AppBarActionName(fontSize: fontSize * 0.8)],
      centerTitle: true,
      backgroundColor: Colors.lightBlueAccent,
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentUserLocation,
        minZoom: AppConstants.minZoom,
        initialRotation: _rotation,
        onTap: (_, __) {
          if (mounted) {
            setState(() {
              _routePoints.clear();
              _distance = 0.0;
              _selectedUserId = null;
              _currentZoom =
                  AppConstants.defaultZoom; // Reset zoom when clearing polyline
              _mapController.move(_currentUserLocation, _currentZoom!);
            });
          }
        },
      ),
      children: [
        TileLayer(urlTemplate: AppConstants.tileUrl),
        MarkerLayer(markers: _buildMarkers()),
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
    );
  }

  List<Marker> _buildMarkers() {
    final size = MediaQuery.of(context).size;
    final markerSize = size.width * 0.08;

    final markers = _userLocations.map((loc) {
      final user = _users.firstWhere(
        (u) => u.id == loc.userid,
        orElse: () => User(
          id: 0,
          firstname: "Unknown",
          email: "",
          password: "",
          fullname: '',
          lastname: '',
          profile_pic: '',
          gender: '',
          dob: '',
          status: '',
          koumoku1: '',
          koumoku2: '',
          koumoku3: '',
          koumoku4: '',
          koumoku5: '',
          koumoku6: '',
          koumoku7: '',
          koumoku8: '',
          koumoku9: '',
          koumoku10: '',
        ),
      );
      return Marker(
        point: LatLng(loc.endlatitude, loc.endlongitude),
        width: markerSize * 2,
        height: markerSize * 2.5,
        child: GestureDetector(
          onTap: () => _calculateDistance(
            loc.userid,
            LatLng(loc.endlatitude, loc.endlongitude),
          ),
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
    final fontSize = markerSize * 0.3;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: fontSize * 0.5,
            vertical: fontSize * 0.25,
          ),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(fontSize * 0.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize.clamp(10, 16),
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ClipOval(
          child: Image.asset(
            'assets/person_marker.png',
            width: markerSize * 1.8,
            height: markerSize * 1.8,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.person, size: markerSize * 1.8, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceInfo(double padding, Size size) {
    final isSmallScreen = size.width < AppConstants.smallScreenBreakpoint;
    final isLargeScreen = size.width >= AppConstants.largeScreenBreakpoint;
    final buttonSize = isSmallScreen
        ? 40.0
        : isLargeScreen
            ? 56.0
            : 50.0;
    final spacing = size.height * (isSmallScreen ? 0.015 : 0.02);
    final iconSize = buttonSize * (isSmallScreen ? 0.5 : 0.6);
    final paddingValue = size.width *
        (isSmallScreen
            ? 0.02
            : isLargeScreen
                ? 0.04
                : 0.03);

    final selectedUser = _selectedUserId != null
        ? _users.firstWhere(
            (u) => u.id == _selectedUserId,
            orElse: () => User(
              id: 0,
              firstname: "Unknown",
              email: "",
              password: "",
              fullname: '',
              lastname: '',
              profile_pic: '',
              gender: '',
              dob: '',
              status: '',
              koumoku1: '',
              koumoku2: '',
              koumoku3: '',
              koumoku4: '',
              koumoku5: '',
              koumoku6: '',
              koumoku7: '',
              koumoku8: '',
              koumoku9: '',
              koumoku10: '',
            ),
          )
        : null;

    return Container(
      padding: EdgeInsets.all(padding),
      color: Colors.white.withOpacity(0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedUser != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: selectedUser)),
                  ),
                  child: CircleAvatar(
                    radius: isSmallScreen ? 22 : 25,
                    backgroundImage:
                        const AssetImage('assets/person_marker.png'),
                  ),
                ),
                SizedBox(width: padding * 0.5),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color:
                                  selectedUser.status.toLowerCase() == 'active'
                                      ? Colors.green
                                      : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        selectedUser.fullname,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Last active 25m ago', // Replace with dynamic data
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                            senderId: _user!.id.toString(),
                            receiverId: _selectedUserId.toString() ?? ''),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.chat_rounded,
                          size: iconSize, color: Colors.blueAccent),
                    ),
                  ),
                ),
              ),
              SizedBox(width: padding * 0.5),
              if (_distance > 0 && _selectedUserId != null)
                Expanded(
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(FontAwesomeIcons.car,
                                size: iconSize, color: Colors.black54),
                            SizedBox(width: padding * 0.25),
                            Text(
                              '${_distance.toStringAsFixed(2)} km',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons(Size size) {
    final isSmallScreen = size.width < AppConstants.smallScreenBreakpoint;
    final isLargeScreen = size.width >= AppConstants.largeScreenBreakpoint;
    final padding = size.width * 0.05;
    final buttonSize = isSmallScreen
        ? 40.0
        : isLargeScreen
            ? 56.0
            : 52.0;
    final spacing = size.height * (isSmallScreen ? 0.015 : 0.02);
    final iconSize = buttonSize * (isSmallScreen ? 0.5 : 0.6);

    return Positioned(
      bottom: padding,
      right: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildFAB(
            icon: Icons.refresh,
            onPressed: _fetchMatchUsers,
            heroTag: 'refresh',
            size: buttonSize,
            iconSize: iconSize,
            isLargeScreen: isLargeScreen,
          ),
          SizedBox(height: spacing),
          Transform.scale(
            scale: isSmallScreen ? 0.8 : 1.0,
            child: Switch(
              value: _isShareLocation,
              onChanged: _toggleLocationSharing,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          SizedBox(height: spacing),
          _buildFAB(
            icon: Icons.explore,
            onPressed: _resetRotation,
            heroTag: 'resetRotation',
            size: buttonSize,
            iconSize: iconSize,
            isLargeScreen: isLargeScreen,
          ),
          SizedBox(height: spacing),
          _buildFAB(
            icon: Icons.my_location,
            onPressed: () => _updateLocation(),
            heroTag: 'updateLocation',
            size: buttonSize,
            iconSize: iconSize,
            isLargeScreen: isLargeScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB({
    required IconData icon,
    required VoidCallback onPressed,
    required String heroTag,
    required double size,
    required double iconSize,
    required bool isLargeScreen,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      mini: size < 50,
      heroTag: heroTag,
      elevation: isLargeScreen ? 0 : 6,
      backgroundColor: isLargeScreen ? Colors.white : null,
      child: Icon(icon,
          size: iconSize,
          color: isLargeScreen ? Colors.blueAccent : Colors.black),
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
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Sidebar(
      onHomeTap: () => _navigate(context, const DistanceTrackerPage()),
      onUsersTap: () => _navigate(context, const UserListScreen()),
      onTrackLocationTap: () => _navigate(context, const DistanceTrackerPage()),
      onChatBoxTap: () => _navigate(context, ChatBoxScreen()),
      onSettingsTap: () => debugPrint("Settings tapped"),
      onLogoutTap: () {
        context.read<AuthBloc>().add(LogoutEvent());
        _navigate(context, AuthScreen());
      },
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }
}
