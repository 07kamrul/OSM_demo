import 'package:bloc/bloc.dart';
import 'package:gis_osm/common/user_storage.dart';
import 'package:gis_osm/data/models/user.dart';
import 'package:gis_osm/services/user_service.dart';
import 'profile_update_event.dart';
import 'profile_update_state.dart';

class ProfileUpdateBloc extends Bloc<ProfileUpdateEvent, ProfileUpdateState> {
  final UserService _userService;

  ProfileUpdateBloc({required UserService userService})
      : _userService = userService,
        super(const ProfileUpdateState()) {
    on<FetchUser>(_onFetchUser);
    on<UpdateUser>(_onUpdateUser);
  }

  Future<void> _onFetchUser(
      FetchUser event, Emitter<ProfileUpdateState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'User ID not found in cache',
        ));
        return;
      }
      final user = await _userService.fetchUser();
      emit(state.copyWith(
        isLoading: false,
        user: user,
        userId: userId,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch user: $e',
      ));
    }
  }

  Future<void> _onUpdateUser(
      UpdateUser event, Emitter<ProfileUpdateState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final updatedUser = await _userService.updateUser(event.user);
      emit(state.copyWith(
        isLoading: false,
        user: updatedUser,
        errorMessage: null,
        updateSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update profile: $e',
        updateSuccess: false,
      ));
    }
  }
}
