part of 'user_location_bloc.dart';

abstract class UserLocationState extends Equatable {
  const UserLocationState();

  @override
  List<Object> get props => [];
}

class UserLocationInitial extends UserLocationState {}

class UserLocationLoading extends UserLocationState {}

class UserLocationLoaded extends UserLocationState {
  final List<UserLocation> locations;

  const UserLocationLoaded(this.locations);

  @override
  List<Object> get props => [locations];
}

class UserLocationSuccess extends UserLocationState {
  final String message;

  const UserLocationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class UserLocationError extends UserLocationState {
  final String message;

  const UserLocationError(this.message);

  @override
  List<Object> get props => [message];
}