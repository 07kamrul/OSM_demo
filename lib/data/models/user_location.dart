class UserLocation {
  final int? id;
  final int userId;
  final double latitude;
  final double longitude;
  final bool isSharingLocation;

  UserLocation({
    this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.isSharingLocation,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'],
      userId: json['userId'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      isSharingLocation: json['isSharingLocation'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'isSharingLocation': isSharingLocation,
    };
  }
}