class User {
  final int? id;
  final String fullname;
  final String firstname;
  final String lastname;
  final String email;
  final String password;

  User({
    this.id,
    required this.fullname,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullname: json['fullname'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      password: json['password'],
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
    };
  }
}