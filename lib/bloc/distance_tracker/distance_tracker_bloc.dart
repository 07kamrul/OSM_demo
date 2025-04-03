import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/location_storage.dart';
import '../../common/user_storage.dart';
import '../../data/models/user_location.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/match_user_repository.dart';
import '../../data/repositories/user_location_repository.dart';
import '../../enum.dart';
import '../../services/location_service.dart';
import '../../services/user_service.dart';
import 'distance_tracker_event.dart';
import 'distance_tracker_state.dart';

class DistanceTrackerBloc
    extends Bloc<DistanceTrackerEvent, DistanceTrackerState> {
  final UserLocationRepository _userLocationRepository;
  final AuthRepository _userRepository;
  final MatchUsersRepository _matchUsersRepository;
  final UserService _userService;
  final MapController mapController;
  Timer? _locationUpdateTimer;
  LatLng? _previousLocation;
  bool _isClosed = false;

  DistanceTrackerBloc({
    required UserLocationRepository userLocationRepository,
    required AuthRepository userRepository,
    required MatchUsersRepository matchUsersRepository,
    required UserService userService,
    required this.mapController,
  })  : _userLocationRepository = userLocationRepository,
        _userRepository = userRepository,
        _matchUsersRepository = matchUsersRepository,
        _userService = userService,
        super(const DistanceTrackerState(currentUserLocation: LatLng(0, 0))) {
    on<InitializeMap>(_onInitializeMap);
    on<InitializeData>(_onInitializeData);
    on<UpdateLocation>(_onUpdateLocation);
    on<CalculateDistance>(_onCalculateDistance);
    on<ToggleLocationSharing>(_onToggleLocationSharing);
    on<ResetRotation>(_onResetRotation);
    on<ClearRoute>(_onClearRoute);
    on<FetchMatchUsers>(_onFetchMatchUsers);
  }

  Future<void> _onInitializeMap(
      InitializeMap event, Emitter<DistanceTrackerState> emit) async {
    emit(state.copyWith(isLoading: false));
    // Defer heavy initialization to after the map is rendered
    add(InitializeData());
  }

  Future<void> _onInitializeData(
      InitializeData event, Emitter<DistanceTrackerState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) throw 'User ID not found';

      final user = await _userService.fetchUser();
      final userLocation =
          await _userLocationRepository.getUserLocationByUserId(userId);
      final location = await LocationService.getCurrentLocation();
      final users = await _userService.fetchUsers();
      final matchUsers = await _matchUsersRepository.getMatchUsers(userId);

      // Save the location to cache
      CachedLocationStorage.saveLocation(location);

      emit(state.copyWith(
        currentUserLocation: location,
        userLocations: matchUsers.map((m) => m.location).toList(),
        users: users,
        matchUsers: matchUsers,
        user: user,
        userLocation: userLocation,
        isShareLocation: userLocation.issharinglocation,
        isLoading: false,
        currentZoom: AppConstants.defaultZoom,
      ));

      _previousLocation =
          LatLng(userLocation.startlatitude, userLocation.startlongitude);
      mapController.move(location, AppConstants.defaultZoom);
      _startPeriodicUpdates();
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Initialization failed: $e'));
    }
  }

  Future<void> _onUpdateLocation(
      UpdateLocation event, Emitter<DistanceTrackerState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final location = await LocationService.getCurrentLocation();
      if (_previousLocation == null || _previousLocation != location) {
        emit(state.copyWith(currentUserLocation: location));
        if (state.routePoints.isEmpty) {
          mapController.move(
              location, state.currentZoom ?? AppConstants.defaultZoom);
          emit(state.copyWith(currentZoom: mapController.camera.zoom));
        }
        _previousLocation = location;
        CachedLocationStorage.saveLocation(location);
      }
      // ... rest of the logic
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
          errorMessage: 'Error updating location: $e', isLoading: false));
    }
  }

  Future<void> _onCalculateDistance(
      CalculateDistance event, Emitter<DistanceTrackerState> emit) async {
    try {
      final result = await LocationService.getRouteDistance(
          state.currentUserLocation, event.target);
      if (result?.distance != null) {
        emit(state.copyWith(
          distance: result!.distance!,
          routePoints: result.routePoints,
          selectedUserId: event.userId,
        ));
        _fitMapToRoute();
        emit(state.copyWith(currentZoom: mapController.camera.zoom));
      }

      if (state.userLocation != null) {
        final userResult = await LocationService.getRouteDistance(
            LatLng(state.userLocation!.startlatitude,
                state.userLocation!.startlongitude),
            state.currentUserLocation);
        if (userResult != null && userResult.distance * 1000 >= 10) {
          add(UpdateLocation());
        }
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error calculating distance: $e'));
    }
  }

  Future<void> _onToggleLocationSharing(
      ToggleLocationSharing event, Emitter<DistanceTrackerState> emit) async {
    emit(state.copyWith(isShareLocation: event.value));
    if (event.value) {
      _startPeriodicUpdates();
    } else {
      _stopPeriodicUpdates();
    }
    await _updateUserLocationSharing(emit);
  }

  Future<void> _onResetRotation(
      ResetRotation event, Emitter<DistanceTrackerState> emit) async {
    mapController.rotate(0);
    emit(state.copyWith(rotation: 0.0));
  }

  Future<void> _onClearRoute(
      ClearRoute event, Emitter<DistanceTrackerState> emit) async {
    emit(state.copyWith(
      routePoints: [],
      distance: 0.0,
      selectedUserId: null,
      currentZoom: AppConstants.defaultZoom,
    ));
    mapController.move(state.currentUserLocation, AppConstants.defaultZoom);
  }

  Future<void> _onFetchMatchUsers(
      FetchMatchUsers event, Emitter<DistanceTrackerState> emit) async {
    await _fetchMatchUsers(
        state.user?.id ?? await UserStorage.getUserId(), emit);
  }

  Future<void> _fetchMatchUsers(
      int? userId, Emitter<DistanceTrackerState> emit) async {
    try {
      if (userId == null) throw 'User ID not found';
      CachedLocationStorage.clearLocation();
      final matchUsers = await _matchUsersRepository.getMatchUsers(userId);
      emit(state.copyWith(
        matchUsers: matchUsers,
        userLocations: matchUsers.map((m) => m.location).toList(),
        isLoading: false,
      ));
      if (_previousLocation == null ||
          _previousLocation != state.currentUserLocation) {
        mapController.move(state.currentUserLocation,
            state.currentZoom ?? AppConstants.defaultZoom);
        _previousLocation = state.currentUserLocation;
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load match users: $e'));
    }
  }

  Future<void> _updateUserLocationSharing(
      Emitter<DistanceTrackerState> emit) async {
    if (state.userLocation != null) {
      final userId = await UserStorage.getUserId();
      if (userId != null) {
        final updatedLocation = UserLocation(
          id: state.userLocation!.id,
          userid: userId,
          startlatitude: state.userLocation!.startlatitude,
          startlongitude: state.userLocation!.startlongitude,
          endlatitude: state.currentUserLocation.latitude,
          endlongitude: state.currentUserLocation.longitude,
          issharinglocation: state.isShareLocation,
        );
        await _userLocationRepository.updateUserLocation(updatedLocation);
        emit(state.copyWith(userLocation: updatedLocation));
      }
    }
  }

  Future<void> _updateUserLocation(UserLocation? userLocation) async {
    if (userLocation == null) return;
    final result = await LocationService.getRouteDistance(
        LatLng(userLocation.startlatitude, userLocation.startlongitude),
        state.currentUserLocation);
    if (result != null && result.distance * 1000 >= 10) {
      final updatedLocation = UserLocation(
        id: userLocation.id,
        userid: userLocation.userid,
        startlatitude: state.currentUserLocation.latitude,
        startlongitude: state.currentUserLocation.longitude,
        endlatitude: state.currentUserLocation.latitude,
        endlongitude: state.currentUserLocation.longitude,
        issharinglocation: state.isShareLocation,
      );
      await _userLocationRepository.updateUserLocation(updatedLocation);
      emit(state.copyWith(userLocation: updatedLocation));
    }
  }

  Future<void> _recalculateDistanceForSelectedUser(
      Emitter<DistanceTrackerState> emit) async {
    final selectedUserLocation = state.userLocations.firstWhere(
      (loc) => loc.userid == state.selectedUserId,
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
    add(CalculateDistance(
      state.selectedUserId!,
      LatLng(
          selectedUserLocation.endlatitude, selectedUserLocation.endlongitude),
    ));
  }

  void _startPeriodicUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer =
        Timer.periodic(AppConstants.locationUpdateInterval, (_) {
      if (!_isClosed) {
        add(UpdateLocation());
      }
    });
  }

  void _stopPeriodicUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  void _fitMapToRoute() {
    if (state.routePoints.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(state.routePoints);
    mapController.fitCamera(CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.all(50),
    ));
  }

  @override
  Future<void> close() {
    _isClosed = true;
    _stopPeriodicUpdates();
    return super.close();
  }
}
