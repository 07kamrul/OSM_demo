import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class DistanceTrackerEvent extends Equatable {
  const DistanceTrackerEvent();

  @override
  List<Object?> get props => [];
}

class InitializeData extends DistanceTrackerEvent {}

class UpdateLocation extends DistanceTrackerEvent {}

class CalculateDistance extends DistanceTrackerEvent {
  final int userId;
  final LatLng target;

  const CalculateDistance(this.userId, this.target);

  @override
  List<Object?> get props => [userId, target];
}

class ToggleLocationSharing extends DistanceTrackerEvent {
  final bool value;

  const ToggleLocationSharing(this.value);

  @override
  List<Object?> get props => [value];
}

class ResetRotation extends DistanceTrackerEvent {}

class ClearRoute extends DistanceTrackerEvent {}

class FetchMatchUsers extends DistanceTrackerEvent {}

class InitializeMap extends DistanceTrackerEvent {}
