import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedLocationStorage {
  static const String _lastLatitude = 'last_latitude';
  static const String _lastLongitude = 'last_longitude';

  static Future<LatLng> getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final latitude = prefs.getDouble(_lastLatitude) ?? position.latitude;
    final longitude = prefs.getDouble(_lastLongitude) ?? position.longitude;
    return LatLng(latitude, longitude);
  }

  static Future<void> saveLocation(LatLng location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lastLatitude, location.latitude);
    await prefs.setDouble(_lastLongitude, location.longitude);
  }

  static Future<void> clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastLatitude);
    await prefs.remove(_lastLongitude);
  }
}
