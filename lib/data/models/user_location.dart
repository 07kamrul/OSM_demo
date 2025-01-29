import 'package:equatable/equatable.dart';

class UserLocation extends Equatable {
  final int id;
  final int userId;
  final double latitude;
  final double longitude;
  final bool isSharingLocation;

  const UserLocation({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.isSharingLocation,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'],
      userId: json['userId'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      isSharingLocation: json['isSharingLocation'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'latitude': latitude,
    'longitude': longitude,
    'isSharingLocation': isSharingLocation,
  };

  @override
  List<Object?> get props => [id, userId, latitude, longitude, isSharingLocation];
}
