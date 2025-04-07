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
          {
            "type": "service_account",
            "project_id": "gis-osm",
            "private_key_id": "bcbd3f34cbd367a6f8861b1b4fff162b9aac063f",
            "private_key":
                "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDSWLuNfOfTAvqm\nYpWTlCGJVV76UCf+aH0yyBgU4NQqgZ/vPoX/2dxq4kYoJ2zrBPcjYKVM88lrrAQW\nmjx3+JNv7gqXtLCzdd7HduRmbjgyLWkP8OtS1ef6CxEreWmdFJtC6jReoQw+uk14\nR7/Rv8keyg8UwvlsrXT/muf/J0S7uU9a4VqCTWlR3gdQM6ZWQs5iBRLyOwOEYzUr\no+XSzsw15Fw1rgwx9YQMhcJLhVLwUx+FGOLmLzPdQByhFH1o9t4SW5Fk77ulcIGF\nRBt2tg5ZsU/C3i0sL0TZv7tnep+TcX13o3nCu9c28SmRKLw4quRzhCFXi+71j/jx\nKa4lXs3DAgMBAAECggEAJuJWUXJ8nGpZkXZ59h0VEgEhHJ7Cten08vVAVmO1dOIf\ngaeKN+C7OVr44yVeohd55CVSiWYrnubenpsGgJsIDlHvzVmOrK4mb7MPx8uqQcRZ\nPqQnrFl0l6mCFApOtsX/aaBH7BJTZCkmdwy0bf7JHBL4NLtSRn/OOA4XwvgsYZMr\nR8LEE5pMM+7eupI88gx8tJorE7pqEA/8w+zI53aUlICLRwy65Inb035EU4NBL/ey\nEo+qMV3Wk2GDRDX/6e/CuTeyzHeJLBrcuspvv2QZ6wxa2s/A94XWoIcXBb1udS0B\nokCYzm2MH1cyRMT+JydOJuHju0fn+aYTTUaNlGf+0QKBgQDoJEFbhaPAInBYP72I\nsUoPJ79jCDmmJujpk0mZxQ/7wJprXtHlIiBeAmI3vEh85aqyhE0rNrVH6YxJSoEY\nZkv3j2ulyo0Nu8INo8ql1uqUvAla0renIFHiLVh0jYVCXGEoHCnklcx12j0K4gLF\n+bh103C99tgfy1UG+Vf1XfMNWQKBgQDn9wqVWJ2/SIJbYHwK6pwX7tZ7fZ1rmOWE\nSn7AWj/3CpNVMryVl280rQNnssR1yTfca6jw/dmPoHHyctfbF0GBzWoZMyzotNUg\nJYiJFt7IOCiwFx++zEPd5pUj4isziEKAhasXTHRt9V36TC/lIHd3IxYEPj7jDvht\nJ0LRKjIEewKBgCF/gdLkIPILxixl3kLIWoh/UtXGjRMV0ExMTbWbwyev7liKET3A\nQ+1s6KFkUQ180rn572zJ8zTSVcUJtEFCGbo6fu0oolwV+PWg6hAuSCF4VN0/RPMf\n7dD2fCotdcpSrE5uafkrSJrFCEP2wzGwTFbsUPuIkD1eSQG9n1yv1u/ZAoGBAM9V\nfr4ysP0SgIHQYc8YGGFD9631f0l3Jl7yfwzLHjVf3ITgjrNe4eVBZ7O+k9979VQt\nXpnZLCc2j+LXR5zq0oCE7HqNxWxShdTv93QhXwuzNpr+cD+IMHkc6t1iAJ9VAawC\nzgRLMB5AnLlmc8DnHiD82Wb9hBRLgz19RDnU71QVAoGBAMCiXuKntAP+8cDgHeYh\n9s9g4i5RmeHnRZM/x9HhxctpUjEwp+eXzIxu6qyYaA9h2IuT52MmOlmWdVfx5hnO\n8xeDDqj5U41UOsS7pimXBBCdDZ1YBlwOu7/f/dQ9r6VIK+vcnNHrzRZFCa4m0zta\nEjn32HzopJZuXeHzQEuUCVdf\n-----END PRIVATE KEY-----\n",
            "client_email":
                "firebase-adminsdk-fbsvc@gis-osm.iam.gserviceaccount.com",
            "client_id": "114851365542700063638",
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url":
                "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url":
                "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40gis-osm.iam.gserviceaccount.com",
            "universe_domain": "googleapis.com"
          },
        ),
        scopes);

    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
