import 'package:flutter/material.dart';
import 'package:gis_osm/data/repositories/message_repository.dart';

import '../data/models/message.dart';
import '../services/signal_r_service.dart';
import '../widgets/app_bar_action_name.dart';

class ChatScreen extends StatefulWidget {
  final int senderId;
  final int receiverId;

  ChatScreen({required this.senderId, required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageRepository _apiService = MessageRepository();
  final SignalRService _signalRService = SignalRService();
  final TextEditingController _controller = TextEditingController();
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _signalRService.startConnection();
    _signalRService.listenForMessages((user, message) {
      setState(() {
        _messages.add(Message(
          messageId: _messages.length + 1,
          senderId: widget.senderId,
          receiverId: widget.receiverId,
          content: message,
          sentAt: DateTime.now(),
          isRead: false,
        ));
      });
    });
  }

  Future<void> _loadMessages() async {
    final messages =
        await _apiService.getMessages(widget.senderId, widget.receiverId);
    setState(() {
      _messages = messages;
    });
  }

  Future<void> _sendMessage() async {
    final content = _controller.text;
    if (content.isNotEmpty) {
      await _apiService.sendMessage(
          widget.senderId, widget.receiverId, content);
      _signalRService.sendMessage("User", content);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _signalRService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.width * 0.04;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
        actions: [AppBarActionName(fontSize: fontSize * 0.8)],
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message.content),
                  subtitle: Text("Sent at: ${message.sentAt}"),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Enter your message"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
