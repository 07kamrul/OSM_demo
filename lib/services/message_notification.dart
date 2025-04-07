import 'package:googleapis_auth/auth_io.dart' as auth;

class MessageNotification {
  static sendNotificationToSelectedDriver() async {
    final String key = await getAccessToken();
    String url = 'https://fcm.googleapis.com/v1/projects/gis-osm/messages:send';

    var header = <String, String>{
      'Content-Type': 'application/json',
      'Authrozation': 'Bearer $key',
    };
  }

  static Future<String> getAccessToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/userinfo.email',
    ];

    final client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(
          {},
        ),
        scopes);

    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
