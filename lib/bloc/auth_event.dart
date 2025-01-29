part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RegisterUserEvent extends AuthEvent {
  final User user;

  RegisterUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginUserEvent extends AuthEvent {
  final String email;
  final String password;

  LoginUserEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}
