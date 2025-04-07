import 'package:flutter/cupertino.dart';
import 'package:gis_osm/services/server_key.dart';
import 'package:googleapis/connectors/v1.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class MessageNotification {
  static sendNotificationToSelectedDriver() async {
    final String serverKey = await ServerKey.getAccessToken();
    String url = 'https://fcm.googleapis.com/v1/projects/gis-osm/messages:send';

    var header = <String, String>{
      'Content-Type': 'application/json',
      'Authrozation': 'Bearer $serverKey',
    };
  }
}
