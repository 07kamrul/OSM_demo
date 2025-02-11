import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user_location.dart';
import '../../data/repositories/user_location_repository.dart';

part 'user_location_event.dart';
part 'user_location_state.dart';

class UserLocationBloc extends Bloc<UserLocationEvent, UserLocationState> {
  final UserLocationRepository userLocationRepository;

  UserLocationBloc({required this.userLocationRepository})
      : super(UserLocationInitial()) {
    on<GetAllUserLocationsEvent>((event, emit) async {
      emit(UserLocationLoading());
      try {
        final locations = await userLocationRepository.getAllUserLocations();
        emit(UserLocationLoaded(locations));
      } catch (e) {
        emit(UserLocationError(e.toString()));
      }
    });

    on<UpdateUserLocationEvent>((event, emit) async {
      emit(UserLocationLoading());
      try {
        await userLocationRepository.updateUserLocation(event.userLocation);
        emit(UserLocationSuccess('User location added successfully!'));
      } catch (e) {
        emit(UserLocationError(e.toString()));
      }
    });
  }
}