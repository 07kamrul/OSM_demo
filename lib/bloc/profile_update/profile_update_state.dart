import 'package:equatable/equatable.dart';
import 'package:gis_osm/data/models/user.dart';

class ProfileUpdateState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final User? user;
  final int? userId;
  final bool updateSuccess;

  const ProfileUpdateState({
    this.isLoading = true,
    this.errorMessage,
    this.user,
    this.userId,
    this.updateSuccess = false,
  });

  ProfileUpdateState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? user,
    int? userId,
    bool? updateSuccess,
  }) {
    return ProfileUpdateState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
      userId: userId ?? this.userId,
      updateSuccess: updateSuccess ?? this.updateSuccess,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        user,
        userId,
        updateSuccess,
      ];
}
