import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return LatLng(0, 0);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return LatLng(0, 0);
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  static void listenToLocationChanges(Function(LatLng) onLocationUpdate) {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      onLocationUpdate(LatLng(position.latitude, position.longitude));
    });
  }

  static Future<RouteResult?> getRouteDistance(
      LatLng start, LatLng end) async {
    final String url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final distanceMeters = data['routes'][0]['distance'];
        final coordinates = data['routes'][0]['geometry']['coordinates'];

        final routePoints = coordinates
            .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
            .toList();

        return RouteResult(
          distance: distanceMeters / 1000, // Convert to kilometers
          routePoints: routePoints,
        );
      } else {
        throw Exception('Failed to fetch road distance.');
      }
    } catch (e) {
      print('Error fetching road distance: $e');
      return null;
    }
  }

}

class RouteResult {
  final double distance;
  final List<LatLng> routePoints;

  RouteResult({required this.distance, required this.routePoints});
}
