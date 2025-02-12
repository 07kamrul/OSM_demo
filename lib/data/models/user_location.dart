class UserLocation {
  final int? id;
  final int userid;
  final double latitude;
  final double longitude;
  final bool issharinglocation;

  UserLocation({
    this.id,
    required this.userid,
    required this.latitude,
    required this.longitude,
    required this.issharinglocation,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id']?? 0,
      userid: json['userid']??0,
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      issharinglocation: json['issharinglocation'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': userid, // Use lowercase 'userid' to match the JSON key
      'latitude': latitude,
      'longitude': longitude,
      'issharinglocation': issharinglocation, // Use lowercase to match the JSON key
    };
  }
}