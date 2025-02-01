import '../../data/models/user.dart';

abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final User user;
  RegisterEvent(this.user);
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent(this.email, this.password);
}
