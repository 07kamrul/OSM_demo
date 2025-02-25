import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/user_storage.dart';
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

        if (response['success'] == false) {
          // Extract error details
          final String errorMessage = response['message'] ?? 'Registration failed';
          final errors = response['errors'] as Map<String, dynamic>?;

          // Construct a detailed error message from the 'errors' field
          String detailedError = errorMessage;
          if (errors != null && errors.isNotEmpty) {
            // Take the first error from each field (e.g., "email")
            detailedError = errors.entries
                .map((entry) => entry.value is List ? entry.value[0] : entry.value)
                .join(', ');
          }
          throw Exception(detailedError);
        }

        var userInfo = response['user'];

        final userId = userInfo['id'] ?? -1;
        final email = userInfo['email'];
        final fullname = userInfo['fullname'];
        final firstname = userInfo['firstname'];
        final lastname = userInfo['lastname'];

        if (userId == -1) {
          throw Exception("Invalid user ID received from the server.");
        }

        await UserStorage.saveUser(userId, email, fullname, firstname, lastname);
        emit(AuthSuccess(response['Message'] ?? 'User registered successfully!'));
      } catch (e) {
        emit(AuthFailure(error: e.toString().replaceFirst('Exception: ', ''))); // Clean up the error message
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      var msg = '';

      try {
        final response = await authRepository.login(event.email, event.password);

        var userInfo = response['user'];
        msg = response['message'];

        final userId = userInfo['id'] ?? -1;
        final email = userInfo['email'];
        final fullname = userInfo['fullname'];
        final firstname = userInfo['firstname'];
        final lastname = userInfo['lastname'];

        if (userId == -1) {
          throw Exception("Invalid user ID received from the server.");
        }

        await UserStorage.saveUser(userId, email, fullname, firstname, lastname);
        emit(AuthSuccess(response['Message'] ?? 'Login successful!'));
      } catch (e) {
        emit(AuthFailure(error: msg));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await UserStorage.clearUser();
      emit(AuthInitial());
    });

  }
}
