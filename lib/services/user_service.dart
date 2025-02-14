import 'package:gis_osm/data/repositories/auth_repository.dart';
import 'package:gis_osm/common/user_storage.dart';

import '../data/models/user.dart';

class UserService {
  final AuthRepository _userRepository = AuthRepository();

  Future<User> fetchUser() async {
    try {
      int? userId = await UserStorage.getUserId();
      if (userId != null) {
        final user = await _userRepository.getUser(userId);
        return user;
      } else {
        throw Exception('User ID not found in storage.');
      }
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }
}