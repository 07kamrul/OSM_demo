import 'package:signalr_core/signalr_core.dart';

import '../config/api_config.dart';

class SignalRService {
  late HubConnection _hubConnection;

  Future<void> startConnection() async {
    _hubConnection = HubConnectionBuilder()
        .withUrl('${ApiConfig.serverBaseUrl}') // Update with your SignalR URL
        .build();

    await _hubConnection.start();
  }

  void listenForMessages(
      Function(String user, String message) onMessageReceived) {
    _hubConnection.on("ReceiveMessage", (arguments) {
      onMessageReceived(arguments![0], arguments[1]);
    });
  }

  Future<void> sendMessage(String user, String message) async {
    await _hubConnection.invoke("SendMessage", args: [user, message]);
  }

  void dispose() {
    _hubConnection.stop();
  }
}
