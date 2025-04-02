import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedLocation {
  Future<LatLng> getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final latitude = prefs.getDouble('last_latitude') ?? position.latitude;
    final longitude = prefs.getDouble('last_longitude') ?? position.longitude;
    return LatLng(latitude, longitude);
  }

  Future<void> saveLocation(LatLng location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_latitude', location.latitude);
    await prefs.setDouble('last_longitude', location.longitude);
  }
}
