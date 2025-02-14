import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const String _userIdKey = 'userId';
  static const String _emailKey = 'email';
  static const String _fullnameKey = 'fullname';
  static const String _firstnameKey = 'firstname';
  static const String _lastnameKey = 'lastname';

  static Future<void> saveUser(int userId, String email, String fullname, String firstname, String lastname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_fullnameKey, fullname);
    await prefs.setString(_firstnameKey, firstname);
    await prefs.setString(_lastnameKey, lastname);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

 static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fullnameKey);
  }

 static Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_firstnameKey);
  }

 static Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastnameKey);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
  }
}