import 'package:equatable/equatable.dart';
import 'package:gis_osm/data/models/user.dart';

abstract class ProfileUpdateEvent extends Equatable {
  const ProfileUpdateEvent();

  @override
  List<Object?> get props => [];
}

class FetchUser extends ProfileUpdateEvent {}

class UpdateUser extends ProfileUpdateEvent {
  final User user;

  const UpdateUser(this.user);

  @override
  List<Object?> get props => [user];
}
