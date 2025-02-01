import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await authRepository.register(event.user);
        emit(AuthSuccess(response['Message'] ?? 'User registered successfully!'));
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await authRepository.login(event.email, event.password);
        emit(AuthSuccess(response['Message'] ?? 'Login successful!'));
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });
  }
}
