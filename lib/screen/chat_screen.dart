import 'package:flutter/material.dart';
import 'package:gis_osm/data/models/message.dart';
import 'package:gis_osm/services/message_service.dart';
import '../data/models/user.dart';
import '../services/user_service.dart';
import 'distance_tracker_screen.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _messageController = TextEditingController();
  final UserService _userService = UserService();

  Future<User>? _userFuture;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    int receiverId = int.tryParse(widget.receiverId) ?? 0;
    _userFuture =
        _fetchUser(receiverId); // Fetch user when the screen initializes
  }

  Future<User> _fetchUser(int userId) async {
    try {
      if (userId != 0) {
        final user = await _userService.fetchUserInfo(userId);
        return user;
      } else {
        throw 'User ID not found';
      }
    } catch (e) {
      throw ('Failed to load user: $e');
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _messageService.sendMessage(
          widget.receiverId, _messageController.text);
      _messageController.clear(); // Clear input after sending message
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => DistanceTrackerScreen()),
                  );
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                ),
              ),
              SizedBox(width: 10),
              // Use FutureBuilder to handle user data loading asynchronously
              FutureBuilder<User>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Show a loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // Handle errors
                  } else if (!snapshot.hasData) {
                    return Text('No user data'); // Handle no data case
                  } else {
                    final user = snapshot.data!;
                    return Column(
                      children: [
                        Text(user.firstname), // Display user's first name
                      ],
                    );
                  }
                },
              ),
            ],
          ),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: _messageService.getMessages(
                    widget.senderId, widget.receiverId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }

                  final messages = snapshot.data!;
                  return ListView.builder(
                    reverse: true, // Latest messages at the bottom
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender = message.senderId == widget.senderId;
                      return _buildMessageBubble(message, isSender);
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isSender) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSender ? Colors.lightBlueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isSender ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.sentAt.toDate().hour}:${message.sentAt.toDate().minute}',
              style: TextStyle(
                color: isSender ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
            if (!isSender && !message.isRead)
              const Text(
                'Unread',
                style: TextStyle(color: Colors.red, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.lightBlueAccent),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
