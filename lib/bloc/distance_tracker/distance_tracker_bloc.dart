import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  bool isMapInitialized = false;

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
    on<LoadInitialData>(_onLoadInitialData);
    on<UpdateLocation>(_onUpdateLocation);
    on<CalculateDistance>(_onCalculateDistance);
    on<ToggleLocationSharing>(_onToggleLocationSharing);
    on<ResetRotation>(_onResetRotation);
    on<ClearRoute>(_onClearRoute);
    on<FetchMatchUsers>(_onFetchMatchUsers);
    on<UpdateZoom>(_onUpdateZoom); // New event handler
  }

  Future<void> _onInitializeMap(
      InitializeMap event, Emitter<DistanceTrackerState> emit) async {
    isMapInitialized = true;
    emit(state.copyWith(
        isLoading: false, currentZoom: AppConstants.defaultZoom));
  }

  Future<void> _onLoadInitialData(
      LoadInitialData event, Emitter<DistanceTrackerState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) throw 'User ID not found';

      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        await CachedLocationStorage.saveLocation(location);
      }

      final user = await _userService.fetchUser();
      final userLocation =
          await _userLocationRepository.getUserLocationByUserId(userId);

      emit(state.copyWith(
        currentUserLocation: location ?? state.currentUserLocation,
        user: user,
        userLocation: userLocation,
        isShareLocation: userLocation.issharinglocation,
        isLoading: false,
        currentZoom: state.currentZoom ?? AppConstants.defaultZoom,
      ));

      if (isMapInitialized && location != null) {
        mapController.move(
            location, state.currentZoom ?? AppConstants.defaultZoom);
      }

      final users = await _userService.fetchUsers();
      final fetchMatchUsers = await _matchUsersRepository.getMatchUsers(userId);
      final matchUsers =
          fetchMatchUsers.where((u) => u.distance * 1000 <= 200).toList();
      emit(state.copyWith(
        userLocations: matchUsers.map((m) => m.location).toList(),
        users: users,
        matchUsers: matchUsers,
      ));

      _previousLocation = state.currentUserLocation;
      _startPeriodicUpdates();
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Initialization failed: $e'));
    }
  }

  Future<void> _onUpdateLocation(
      UpdateLocation event, Emitter<DistanceTrackerState> emit) async {
    try {
      final location = await LocationService.getCurrentLocation();

      if (location != null) {
        emit(state.copyWith(currentUserLocation: location));

        final isInitialMove = state.routePoints.isEmpty;

        if (isInitialMove && isMapInitialized) {
          mapController.move(
              location, state.currentZoom ?? AppConstants.defaultZoom);
        }

        _previousLocation = location;
        await CachedLocationStorage.saveLocation(location);
        await _updateUserLocationSharing(emit);
      } else {
        emit(state.copyWith(errorMessage: 'Location is null'));
      }
    } catch (e, stackTrace) {
      print('Exception during location update: $e\n$stackTrace');
      emit(state.copyWith(errorMessage: 'Error updating location'));
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
    emit(state.copyWith(routePoints: [], distance: 0.0, selectedUserId: null));
    if (isMapInitialized) {
      mapController.move(state.currentUserLocation,
          state.currentZoom ?? AppConstants.defaultZoom);
    }
  }

  Future<void> _onFetchMatchUsers(
      FetchMatchUsers event, Emitter<DistanceTrackerState> emit) async {
    try {
      final userId = state.user?.id ?? await UserStorage.getUserId();
      if (userId != null) {
        final matchUsers = await _matchUsersRepository.getMatchUsers(userId);
        emit(state.copyWith(
          matchUsers: matchUsers,
          userLocations: matchUsers.map((m) => m.location).toList(),
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load match users: $e'));
    }
  }

  Future<void> _onUpdateZoom(
      UpdateZoom event, Emitter<DistanceTrackerState> emit) async {
    emit(state.copyWith(currentZoom: event.zoom));
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

  void _startPeriodicUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer =
        Timer.periodic(AppConstants.locationUpdateInterval, (_) {
      if (!_isClosed) add(UpdateLocation());
    });
  }

  void _stopPeriodicUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  void _fitMapToRoute() {
    if (state.routePoints.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(state.routePoints);
    // Respect current zoom if within reasonable bounds
    final currentZoom = state.currentZoom ?? AppConstants.defaultZoom;
    mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
        maxZoom: currentZoom.clamp(AppConstants.minZoom, AppConstants.maxZoom),
      ),
    );
  }

  @override
  Future<void> close() {
    _isClosed = true;
    _stopPeriodicUpdates();
    return super.close();
  }
}
