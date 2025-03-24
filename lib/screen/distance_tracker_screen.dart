import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/distance_tracker/distance_tracker_bloc.dart';
import '../bloc/distance_tracker/distance_tracker_event.dart';
import '../bloc/distance_tracker/distance_tracker_state.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/match_user_repository.dart';
import '../data/repositories/user_location_repository.dart';
import '../enum.dart';
import '../screen/auth_screen.dart';
import '../screen/chat_screen.dart';
import '../screen/profile_screen.dart';
import '../screen/sidebar.dart';
import '../screen/user_list_screen.dart';
import '../services/user_service.dart';
import '../widgets/app_bar_action_name.dart';
import 'chat_box_screen.dart';

class DistanceTrackerScreen extends StatelessWidget {
  final MapController _mapController = MapController();

  DistanceTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DistanceTrackerBloc(
        userLocationRepository: context.read<UserLocationRepository>(),
        userRepository: context.read<AuthRepository>(),
        matchUsersRepository: context.read<MatchUsersRepository>(),
        userService: context.read<UserService>(),
        mapController: _mapController, // Pass the controller to BLoC
      ),
      child: _DistanceTrackerView(mapController: _mapController),
    );
  }
}

class _DistanceTrackerView extends StatelessWidget {
  final MapController mapController;

  const _DistanceTrackerView({required this.mapController});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.05;

    return Scaffold(
      appBar: _buildAppBar(context, size),
      drawer: _buildDrawer(context),
      body: BlocBuilder<DistanceTrackerBloc, DistanceTrackerState>(
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(child: _buildMap(context, state)),
                  if (state.routePoints.isNotEmpty)
                    _buildDistanceInfo(context, padding, size, state),
                ],
              ),
              _buildFloatingButtons(context, size, state),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator()),
              if (state.errorMessage != null)
                _buildErrorMessage(size, state.errorMessage!),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Size size) {
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

  Widget _buildMap(BuildContext context, DistanceTrackerState state) {
    return FlutterMap(
      mapController: mapController, // Use the local controller
      options: MapOptions(
        initialCenter: state.currentUserLocation,
        minZoom: AppConstants.minZoom,
        initialRotation: state.rotation,
        onTap: (_, __) => context.read<DistanceTrackerBloc>().add(ClearRoute()),
      ),
      children: [
        TileLayer(urlTemplate: AppConstants.tileUrl),
        MarkerLayer(markers: _buildMarkers(context, state)),
        if (state.routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: state.routePoints,
                color: Colors.green,
                strokeWidth: 4.0,
              ),
            ],
          ),
      ],
    );
  }

  List<Marker> _buildMarkers(BuildContext context, DistanceTrackerState state) {
    final size = MediaQuery.of(context).size;
    final markerSize = size.width * 0.08;

    final markers = state.userLocations.map((loc) {
      final user = state.users.firstWhere(
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
          onTap: () => context.read<DistanceTrackerBloc>().add(
                CalculateDistance(
                  loc.userid,
                  LatLng(loc.endlatitude, loc.endlongitude),
                ),
              ),
          child: _buildMarkerContent(user.firstname, markerSize),
        ),
      );
    }).toList();

    markers.add(Marker(
      point: state.currentUserLocation,
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

  Widget _buildDistanceInfo(BuildContext context, double padding, Size size,
      DistanceTrackerState state) {
    final isSmallScreen = size.width < AppConstants.smallScreenBreakpoint;
    final isLargeScreen = size.width >= AppConstants.largeScreenBreakpoint;
    final buttonSize = isSmallScreen
        ? 40.0
        : isLargeScreen
            ? 56.0
            : 50.0;
    final spacing = size.height * (isSmallScreen ? 0.015 : 0.02);
    final iconSize = buttonSize * (isSmallScreen ? 0.5 : 0.6);

    final selectedUser = state.selectedUserId != null
        ? state.users.firstWhere(
            (u) => u.id == state.selectedUserId,
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
                          senderId: state.user!.id.toString(),
                          receiverId: state.selectedUserId.toString(),
                        ),
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
              if (state.distance > 0 && state.selectedUserId != null)
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
                              '${state.distance.toStringAsFixed(2)} km',
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

  Widget _buildFloatingButtons(
      BuildContext context, Size size, DistanceTrackerState state) {
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
            onPressed: () =>
                context.read<DistanceTrackerBloc>().add(FetchMatchUsers()),
            heroTag: 'refresh',
            size: buttonSize,
            iconSize: iconSize,
            isLargeScreen: isLargeScreen,
          ),
          SizedBox(height: spacing),
          Transform.scale(
            scale: isSmallScreen ? 0.8 : 1.0,
            child: Switch(
              value: state.isShareLocation,
              onChanged: (value) => context
                  .read<DistanceTrackerBloc>()
                  .add(ToggleLocationSharing(value)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          SizedBox(height: spacing),
          _buildFAB(
            icon: Icons.explore,
            onPressed: () =>
                context.read<DistanceTrackerBloc>().add(ResetRotation()),
            heroTag: 'resetRotation',
            size: buttonSize,
            iconSize: iconSize,
            isLargeScreen: isLargeScreen,
          ),
          SizedBox(height: spacing),
          _buildFAB(
            icon: Icons.my_location,
            onPressed: () =>
                context.read<DistanceTrackerBloc>().add(UpdateLocation()),
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
      onHomeTap: () => _navigate(context, DistanceTrackerScreen()),
      onUsersTap: () => _navigate(context, const UserListScreen()),
      onTrackLocationTap: () => _navigate(context, DistanceTrackerScreen()),
      onChatBoxTap: () => _navigate(context, const ChatBoxScreen()),
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
