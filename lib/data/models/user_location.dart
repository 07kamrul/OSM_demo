class UserLocation {
  final int? id;
  final int userid;
  final double startlatitude;
  final double startlongitude;
  final double endlatitude;
  final double endlongitude;
  final bool issharinglocation;

  UserLocation({
    this.id,
    required this.userid,
    required this.startlatitude,
    required this.startlongitude,
    required this.endlatitude,
    required this.endlongitude,
    required this.issharinglocation,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'] ?? 0,
      userid: json['userid'] ?? 0,
      startlatitude: json['startlatitude']?.toDouble() ?? 0.0,
      startlongitude: json['startlongitude']?.toDouble() ?? 0.0,
      endlatitude: json['endlatitude']?.toDouble() ?? 0.0,
      endlongitude: json['endlongitude']?.toDouble() ?? 0.0,
      issharinglocation: json['issharinglocation'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': userid,
      'startlatitude': startlatitude,
      'startlongitude': startlongitude,
      'endlatitude': endlatitude,
      'endlongitude': endlongitude,
      'issharinglocation': issharinglocation,
    };
  }
}
