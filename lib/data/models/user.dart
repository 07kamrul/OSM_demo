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
  final String status;
  final String koumoku1;
  final String koumoku2;
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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullname: json['fullname'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      profile_pic: json['profile_pic'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      status: json['status'] ?? '',
      koumoku1: json['koumoku1'] ?? '',
      koumoku2: json['koumoku2'] ?? '',
      koumoku3: json['koumoku3'] ?? '',
      koumoku4: json['koumoku4'] ?? '',
      koumoku5: json['koumoku5'] ?? '',
      koumoku6: json['koumoku6'] ?? '',
      koumoku7: json['koumoku7'] ?? '',
      koumoku8: json['koumoku8'] ?? '',
      koumoku9: json['koumoku9'] ?? '',
      koumoku10: json['koumoku10'] ?? '',
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
      "status": status,
      "koumoku1": koumoku1,
      "koumoku2": koumoku2,
      "koumoku3": koumoku3,
      "koumoku4": koumoku4,
      "koumoku5": koumoku5.isNotEmpty ? koumoku5 : null,
      "koumoku6": koumoku6.isNotEmpty ? koumoku6 : null,
      "koumoku7": koumoku7.isNotEmpty ? koumoku7 : null,
      "koumoku8": koumoku8.isNotEmpty ? koumoku8 : null,
      "koumoku9": koumoku9.isNotEmpty ? koumoku9 : null,
      "koumoku10": koumoku10.isNotEmpty ? koumoku10 : null,
    };
  }
}
