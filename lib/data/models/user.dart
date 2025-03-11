class User {
  final int? id;
  final String fullname;
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final String profile_pic;
  final String gender;
  final String dob;
  final String koumoku1;
  final String koumoku2;
  final String status;
  final String koumoku3;
  final String koumoku4;
  final String koumoku5;
  final String koumoku6;
  final String koumoku7;
  final String koumoku8;
  final String koumoku9;
  final String koumoku10;

  User({
    this.id,
    required this.fullname,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    required this.profile_pic,
    required this.gender,
    required this.dob,
    required this.koumoku1,
    required this.koumoku2,
    required this.status,
    required this.koumoku3,
    required this.koumoku4,
    required this.koumoku5,
    required this.koumoku6,
    required this.koumoku7,
    required this.koumoku8,
    required this.koumoku9,
    required this.koumoku10,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullname:
          json['fullname'] ?? '', // Providing default empty string if null
      firstname:
          json['firstname'] ?? '', // Providing default empty string if null
      lastname:
          json['lastname'] ?? '', // Providing default empty string if null
      email: json['email'] ?? '', // Providing default empty string if null
      password:
          json['password'] ?? '', // Providing default empty string if null
      profile_pic:
          json['profile_pic'] ?? '', // Providing default empty string if null
      gender: json['gender'] ?? '', // Providing default empty string if null
      dob: json['dob'] ?? '', // Providing default empty string if null
      koumoku1:
          json['koumoku1'] ?? '', // Providing default empty string if null
      koumoku2:
          json['koumoku2'] ?? '', // Providing default empty string if null
      status: json['status'] ?? '', // Providing default empty string if null
      koumoku3:
          json['koumoku3'] ?? '', // Providing default empty string if null
      koumoku4:
          json['koumoku4'] ?? '', // Providing default empty string if null
      koumoku5:
          json['koumoku5'] ?? '', // Providing default empty string if null
      koumoku6:
          json['koumoku6'] ?? '', // Providing default empty string if null
      koumoku7:
          json['koumoku7'] ?? '', // Providing default empty string if null
      koumoku8:
          json['koumoku8'] ?? '', // Providing default empty string if null
      koumoku9:
          json['koumoku9'] ?? '', // Providing default empty string if null
      koumoku10:
          json['koumoku10'] ?? '', // Providing default empty string if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullname": fullname,
      "firstname": firstname,
      "lastname": lastname,
      "email": email,
      "password": password,
      "profile_pic": profile_pic,
      "gender": gender,
      "dob": dob,
      "koumoku1": koumoku1,
      "koumoku2": koumoku2,
      "status": status,
      "koumoku3": koumoku3,
      "koumoku4": koumoku4,
      "koumoku5": koumoku5,
      "koumoku6": koumoku6,
      "koumoku7": koumoku7,
      "koumoku8": koumoku8,
      "koumoku9": koumoku9,
      "koumoku10": koumoku10,
    };
  }
}
