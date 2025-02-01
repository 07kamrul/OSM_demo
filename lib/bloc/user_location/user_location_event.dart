part of 'user_location_bloc.dart';

abstract class UserLocationEvent extends Equatable {
  const UserLocationEvent();

  @override
  List<Object> get props => [];
}

class GetAllUserLocationsEvent extends UserLocationEvent {}

class AddUserLocationEvent extends UserLocationEvent {
  final UserLocation userLocation;

  const AddUserLocationEvent(this.userLocation);

  @override
  List<Object> get props => [userLocation];
}

class UpdateUserLocationEvent extends UserLocationEvent {
  final UserLocation userLocation;

  const UpdateUserLocationEvent(this.userLocation);

  @override
  List<Object> get props => [userLocation];
}

class DeleteUserLocationEvent extends UserLocationEvent {
  final int id;

  const DeleteUserLocationEvent(this.id);

  @override
  List<Object> get props => [id];
}