import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gis_osm/data/models/message.dart';
import 'package:gis_osm/data/repositories/message_repository.dart';
import 'package:gis_osm/services/message_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/user.dart';
import '../../services/firebase_apis.dart';
import '../../services/user_service.dart';
import '../distance_tracker_screen.dart';

// Function to parse Firestore snapshot in a background isolate
List<Message> _parseMessages(QuerySnapshot<Map<String, dynamic>> snapshot) {
  return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
}

class ChatScreen extends StatefulWidget {
  final int senderId;
  final int receiverId;

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
  final MessageRepository _messageRepository = MessageRepository();
  final FirebaseAPIService _firebaseAPIService = FirebaseAPIService();
  final UserService _userService = UserService();

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  Future<User>? _userFuture;
  ImageProvider? _personMarkerImage;
  bool _hasPreloadedAssets = false;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser(widget.receiverId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasPreloadedAssets) {
      _preloadAssets();
      _hasPreloadedAssets = true;
    }
  }

  Future<void> _preloadAssets() async {
    _personMarkerImage = const AssetImage('assets/person_marker.png');
    await precacheImage(_personMarkerImage!, context);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<User> _fetchUser(int userId) async {
    try {
      if (userId != 0) {
        return await _userService.fetchUserInfo(userId);
      } else {
        throw 'User ID not found';
      }
    } catch (e) {
      throw 'Failed to load user: $e';
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _messageService.sendMessage(
        widget.receiverId,
        _messageController.text,
        widget.senderId,
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final imageUrl = await _uploadImage(imageFile);
        if (imageUrl != null) {
          await _messageService.sendMessage(
            widget.receiverId,
            imageUrl,
            widget.senderId,
          );
          _scrollToBottom();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    debugPrint('Uploading image: ${imageFile.path}');
    await Future.delayed(const Duration(seconds: 1));
    return 'https://example.com/uploaded_image.jpg';
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo, color: Color(0xFF0088CC)),
                title: const Text('Photo from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF0088CC)),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DistanceTrackerScreen()),
        ),
      ),
      title: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          } else if (snapshot.hasError) {
            return const Text('Error', style: TextStyle(color: Colors.white));
          } else if (!snapshot.hasData) {
            return const Text('Unknown', style: TextStyle(color: Colors.white));
          } else {
            final user = snapshot.data!;
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: _personMarkerImage ??
                      const AssetImage('assets/person_marker.png'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.status.toLowerCase() == 'active'
                          ? 'Active now'
                          : 'Offline',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
      backgroundColor: const Color(0xFF0088CC),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.videocam, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<Message>>(
      stream: _messageService.getMessages(widget.senderId, widget.receiverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Start a conversation!'));
        }

        final messages = snapshot.data!;
        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: messages.length,
          cacheExtent: 1000.0,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isSender = message.senderId == widget.senderId;
            return _buildMessageBubble(message, isSender);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isSender) {
    final time = message.sentAt.toDate();
    final isImage = message.content.startsWith('http');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSender) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: _personMarkerImage ??
                  const AssetImage('assets/person_marker.png'),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSender ? const Color(0xFF0088CC) : Colors.grey[200],
                borderRadius: BorderRadius.circular(18).copyWith(
                  topLeft: isSender
                      ? const Radius.circular(18)
                      : const Radius.circular(0),
                  topRight: isSender
                      ? const Radius.circular(0)
                      : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: isSender
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (isImage)
                    CachedNetworkImage(
                      imageUrl: message.content,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 50,
                      ),
                    )
                  else
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isSender ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: isSender ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSender) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon:
                const Icon(Icons.add_circle_outline, color: Color(0xFF0088CC)),
            onPressed: () => _showAttachmentOptions(context),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF0088CC),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
