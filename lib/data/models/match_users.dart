import 'package:gis_osm/data/models/user_location.dart';

class User {
  final int id;
  final String email;
  final String password;
  final String fullname;
  final String firstname;
  final String lastname;
  final String profilePic; // Renamed for Dart convention (camelCase)
  final String gender;
  final String dob;
  final String status;
  final String koumoku1; // Consider renaming these based on their purpose
  final String koumoku2;
  final String koumoku3;
  final String koumoku4;
  final String koumoku5;
  final String koumoku6;
  final String koumoku7;
  final String koumoku8;
  final String koumoku9;
  final String koumoku10;
  final UserLocation location;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.fullname,
    required this.firstname,
    required this.lastname,
    required this.profilePic,
    required this.gender,
    required this.dob,
    required this.status,
    required this.koumoku1,
    required this.koumoku2,
    required this.koumoku3,
    required this.koumoku4,
    required this.koumoku5,
    required this.koumoku6,
    required this.koumoku7,
    required this.koumoku8,
    required this.koumoku9,
    required this.koumoku10,
    required this.location,
  });

  // Factory method to create a User from JSON with proper type checking
  factory User.fromJson(Map<String, dynamic> json) {
    // Ensure id is an integer, default to 0 if missing or invalid
    final idValue = json['id'];
    if (idValue is! int) {
      throw FormatException('Invalid or missing "id" field in JSON: $idValue');
    }

    // Default UserLocation if missing or invalid
    final locationData = json['location'];
    final userLocation = locationData is Map<String, dynamic>
        ? UserLocation.fromJson(locationData)
        : UserLocation(
            id: 0,
            userid: idValue,
            startlatitude: 0.0,
            startlongitude: 0.0,
            endlatitude: 0.0,
            endlongitude: 0.0,
            issharinglocation: false,
          ); // Assuming this is a valid default

    return User(
      id: idValue,
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      fullname: json['fullname'] as String? ?? '',
      firstname: json['firstname'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
      profilePic: json['profile_pic'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      status: json['status'] as String? ?? '',
      koumoku1: json['koumoku1'] as String? ?? '',
      koumoku2: json['koumoku2'] as String? ?? '',
      koumoku3: json['koumoku3'] as String? ?? '',
      koumoku4: json['koumoku4'] as String? ?? '',
      koumoku5: json['koumoku5'] as String? ?? '',
      koumoku6: json['koumoku6'] as String? ?? '',
      koumoku7: json['koumoku7'] as String? ?? '',
      koumoku8: json['koumoku8'] as String? ?? '',
      koumoku9: json['koumoku9'] as String? ?? '',
      koumoku10: json['koumoku10'] as String? ?? '',
      location: userLocation,
    );
  }

  // Method to convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'fullname': fullname,
      'firstname': firstname,
      'lastname': lastname,
      'profile_pic': profilePic,
      'gender': gender,
      'dob': dob,
      'status': status,
      'koumoku1': koumoku1,
      'koumoku2': koumoku2,
      'koumoku3': koumoku3,
      'koumoku4': koumoku4,
      'koumoku5': koumoku5,
      'koumoku6': koumoku6,
      'koumoku7': koumoku7,
      'koumoku8': koumoku8,
      'koumoku9': koumoku9,
      'koumoku10': koumoku10,
      'location': location.toJson(),
    };
  }
}
