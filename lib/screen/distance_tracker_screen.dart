import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gis_osm/services/cached_location.dart';
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
import '../screen/profile_screen.dart';
import '../screen/sidebar.dart';
import '../screen/user_list_screen.dart';
import '../services/user_service.dart';
import '../widgets/app_bar_action_name.dart';
import 'message_screens/chat_box_screen.dart';
import 'message_screens/chat_screen.dart';

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
        mapController: _mapController,
      )..add(InitializeMap()),
      child: _DistanceTrackerView(mapController: _mapController),
    );
  }
}

class _DistanceTrackerView extends StatefulWidget {
  final MapController mapController;

  const _DistanceTrackerView({required this.mapController});

  @override
  State<_DistanceTrackerView> createState() => _DistanceTrackerViewState();
}

class _DistanceTrackerViewState extends State<_DistanceTrackerView> {
  LatLng _initialLocation = const LatLng(0, 0);
  final CachedLocation _cachedLocation = CachedLocation();

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    final cachedLocation =
        await context.read<DistanceTrackerBloc>().getCachedLocation();
    setState(() {
      _initialLocation = cachedLocation;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistanceTrackerBloc>().add(UpdateLocation());
      context.read<DistanceTrackerBloc>().add(FetchMatchUsers());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: BlocBuilder<DistanceTrackerBloc, DistanceTrackerState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final padding = constraints.maxWidth * 0.05;
              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(child: _buildMap(context, state)),
                      if (state.routePoints.isNotEmpty)
                        _buildDistanceInfo(context, padding, state),
                    ],
                  ),
                  _buildFloatingButtons(context, constraints, state),
                  if (state.isLoading) const _LoadingOverlay(),
                  if (state.errorMessage != null)
                    _buildErrorMessage(constraints, state.errorMessage!),
                ],
              );
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Location Tracker',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      titleTextStyle: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontSize: MediaQuery.sizeOf(context).width * 0.04),
      actions: [
        AppBarActionName(fontSize: MediaQuery.sizeOf(context).width * 0.032),
      ],
      centerTitle: true,
      backgroundColor: Colors.lightBlueAccent,
      elevation: 4,
    );
  }

  Widget _buildMap(BuildContext context, DistanceTrackerState state) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: state.currentUserLocation != const LatLng(0, 0)
            ? state.currentUserLocation
            : _initialLocation,
        minZoom: AppConstants.minZoom,
        initialRotation: state.rotation,
        onTap: (_, __) => context.read<DistanceTrackerBloc>().add(ClearRoute()),
      ),
      children: [
        TileLayer(
          urlTemplate: AppConstants.tileUrl,
          tileProvider: CachedTileProvider(),
        ),
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
    final markerSize = MediaQuery.sizeOf(context).width * 0.08;

    return [
      ...state.userLocations.map((loc) {
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
            child:
                _MarkerContent(label: user.firstname, markerSize: markerSize),
          ),
        );
      }),
      Marker(
        point: state.currentUserLocation != const LatLng(0, 0)
            ? state.currentUserLocation
            : _initialLocation,
        width: markerSize * 2,
        height: markerSize * 2.5,
        child: const _MarkerContent(label: "Me"),
      ),
    ];
  }

  Widget _buildDistanceInfo(
      BuildContext context, double padding, DistanceTrackerState state) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < AppConstants.smallScreenBreakpoint;
    final isLargeScreen = size.width >= AppConstants.largeScreenBreakpoint;
    final buttonSize = isSmallScreen
        ? 40.0
        : isLargeScreen
            ? 56.0
            : 50.0;
    final iconSize = buttonSize * 0.6;

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
      width: double.infinity,
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
                    radius: isSmallScreen ? 20 : 25,
                    backgroundImage:
                        const AssetImage('assets/person_marker.png'),
                  ),
                ),
                SizedBox(width: padding * 0.5),
                Flexible(
                  child: _UserInfo(
                      user: selectedUser, isSmallScreen: isSmallScreen),
                ),
              ],
            ),
            SizedBox(height: padding),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionCard(
                icon: Icons.chat_rounded,
                color: Colors.blueAccent,
                size: buttonSize,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      senderId: state.user?.id ?? 0,
                      receiverId: state.selectedUserId ?? 0,
                    ),
                  ),
                ),
              ),
              if (state.distance > 0 && state.selectedUserId != null) ...[
                SizedBox(width: padding * 0.5),
                _ActionCard(
                  icon: FontAwesomeIcons.car,
                  color: Colors.black54,
                  size: buttonSize,
                  text: '${state.distance.toStringAsFixed(2)} km',
                  isSmallScreen: isSmallScreen,
                  onTap: () {},
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons(BuildContext context, BoxConstraints constraints,
      DistanceTrackerState state) {
    final isSmallScreen =
        constraints.maxWidth < AppConstants.smallScreenBreakpoint;
    final isLargeScreen =
        constraints.maxWidth >= AppConstants.largeScreenBreakpoint;
    final padding = constraints.maxWidth * 0.05;
    final buttonSize = isSmallScreen
        ? 40.0
        : isLargeScreen
            ? 56.0
            : 52.0;
    final spacing = constraints.maxHeight * 0.02;
    final iconSize = buttonSize * 0.6;

    return Positioned(
      bottom: padding,
      right: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
      child: Icon(
        icon,
        size: iconSize,
        color: isLargeScreen ? Colors.blueAccent : Colors.black,
      ),
    );
  }

  Widget _buildErrorMessage(BoxConstraints constraints, String message) {
    return Center(
      child: Container(
        width: constraints.maxWidth * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
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

// Reusable Widgets
class _MarkerContent extends StatelessWidget {
  final String label;
  final double? markerSize;

  const _MarkerContent({required this.label, this.markerSize});

  @override
  Widget build(BuildContext context) {
    final effectiveMarkerSize =
        markerSize ?? MediaQuery.sizeOf(context).width * 0.08;
    final fontSize = effectiveMarkerSize * 0.3;

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
            width: effectiveMarkerSize * 1.8,
            height: effectiveMarkerSize * 1.8,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.person,
              size: effectiveMarkerSize * 1.8,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class _UserInfo extends StatelessWidget {
  final User user;
  final bool isSmallScreen;

  const _UserInfo({required this.user, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: user.status.toLowerCase() == 'active'
                    ? Colors.green
                    : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                user.fullname,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Text(
          'Last active 25m ago', // Replace with dynamic data
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final String? text;
  final bool isSmallScreen;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.color,
    required this.size,
    this.text,
    this.isSmallScreen = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.all(size * 0.2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon == FontAwesomeIcons.car)
                  FaIcon(icon, size: size * 0.6, color: color)
                else
                  Icon(icon, size: size * 0.6, color: color),
                if (text != null) ...[
                  SizedBox(width: size * 0.1),
                  Flexible(
                    child: Text(
                      text!,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
      ),
    );
  }
}

class CachedTileProvider extends TileProvider {
  CachedTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return NetworkImage(getTileUrl(coordinates, options));
  }
}
