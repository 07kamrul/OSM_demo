class User {
  final int? id;
  final String fullname;
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final String profile_pic;
  final String gender;
  final DateTime dob;
  final String hobby;
  final String region;
  final String status;

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
    required this.hobby,
    required this.region,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullname: json['fullname'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      password: json['password'],
      profile_pic: json['profile_pic'],
      gender: json['gender'],
      dob: json['dob'],
      hobby: json['hobby'],
      region: json['region'],
      status: json['status'],
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
      "hobby": hobby,
      "region": region,
      "status": status,
    };
  }
}