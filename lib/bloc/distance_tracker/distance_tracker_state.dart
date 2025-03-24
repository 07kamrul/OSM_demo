import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/match_users.dart';
import '../../data/models/user.dart';
import '../../data/models/user_location.dart';

class DistanceTrackerState extends Equatable {
  final LatLng currentUserLocation;
  final List<UserLocation> userLocations;
  final List<User> users;
  final List<LatLng> routePoints;
  final List<MatchUsers> matchUsers;
  final double distance;
  final double rotation;
  final bool isLoading;
  final String? errorMessage;
  final User? user;
  final UserLocation? userLocation;
  final bool isShareLocation;
  final int? selectedUserId;
  final double? currentZoom;

  const DistanceTrackerState({
    required this.currentUserLocation,
    this.userLocations = const [],
    this.users = const [],
    this.routePoints = const [],
    this.matchUsers = const [],
    this.distance = 0.0,
    this.rotation = 0.0,
    this.isLoading = true,
    this.errorMessage,
    this.user,
    this.userLocation,
    this.isShareLocation = false,
    this.selectedUserId,
    this.currentZoom,
  });

  DistanceTrackerState copyWith({
    LatLng? currentUserLocation,
    List<UserLocation>? userLocations,
    List<User>? users,
    List<LatLng>? routePoints,
    List<MatchUsers>? matchUsers,
    double? distance,
    double? rotation,
    bool? isLoading,
    String? errorMessage,
    User? user,
    UserLocation? userLocation,
    bool? isShareLocation,
    int? selectedUserId,
    double? currentZoom,
  }) {
    return DistanceTrackerState(
      currentUserLocation: currentUserLocation ?? this.currentUserLocation,
      userLocations: userLocations ?? this.userLocations,
      users: users ?? this.users,
      routePoints: routePoints ?? this.routePoints,
      matchUsers: matchUsers ?? this.matchUsers,
      distance: distance ?? this.distance,
      rotation: rotation ?? this.rotation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      userLocation: userLocation ?? this.userLocation,
      isShareLocation: isShareLocation ?? this.isShareLocation,
      selectedUserId: selectedUserId ?? this.selectedUserId,
      currentZoom: currentZoom ?? this.currentZoom,
    );
  }

  @override
  List<Object?> get props => [
        currentUserLocation,
        userLocations,
        users,
        routePoints,
        matchUsers,
        distance,
        rotation,
        isLoading,
        errorMessage,
        user,
        userLocation,
        isShareLocation,
        selectedUserId,
        currentZoom,
      ];
}
