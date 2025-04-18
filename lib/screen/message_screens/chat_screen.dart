import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as local_notifications;
import 'package:image_picker/image_picker.dart';
import '../../bloc/chat_screen/chat_screen_bloc.dart';
import '../../bloc/chat_screen/chat_screen_event.dart';
import '../../bloc/chat_screen/chat_screen_state.dart';
import '../../data/models/message.dart';
import '../../data/repositories/message_repository.dart';
import '../../services/message_service.dart';
import '../../services/user_service.dart';
import '../distance_tracker_screen.dart';
import 'chat_box_screen.dart';

class ChatScreen extends StatelessWidget {
  final int senderId;
  final int receiverId;
  final int route;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatScreenBloc(
        MessageService(),
        MessageRepository(),
        UserService(),
        senderId,
        receiverId,
      )..add(LoadChat(senderId, receiverId)),
      child: _ChatScreenView(route: route),
    );
  }
}

class _ChatScreenView extends StatefulWidget {
  final int route;

  const _ChatScreenView({required this.route});

  @override
  State<_ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<_ChatScreenView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final local_notifications.FlutterLocalNotificationsPlugin
      _notificationsPlugin =
      local_notifications.FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotificationsAsync(); // Non-blocking
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _initializeNotificationsAsync() async {
    const local_notifications.AndroidInitializationSettings
        initializationSettingsAndroid =
        local_notifications.AndroidInitializationSettings(
            '@mipmap/ic_launcher');
    const local_notifications.InitializationSettings initializationSettings =
        local_notifications.InitializationSettings(
            android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Color(0xFF0088CC)),
              title: const Text('Photo from Gallery'),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<ChatScreenBloc>()
                    .add(const PickImage(ImageSource.gallery));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0088CC)),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<ChatScreenBloc>()
                    .add(const PickImage(ImageSource.camera));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(child: _buildMessageList(context)),
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
        onPressed: () {
          if (widget.route == 1) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => ChatBoxScreen()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => DistanceTrackerScreen()));
          }
        },
      ),
      title: BlocBuilder<ChatScreenBloc, ChatScreenState>(
        buildWhen: (previous, current) =>
            previous is! ChatLoaded ||
            current is! ChatLoaded ||
            previous != current,
        builder: (context, state) {
          if (state is ChatLoading) {
            return const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            );
          } else if (state is ChatError) {
            return const Text('Error', style: TextStyle(color: Colors.white));
          } else if (state is ChatLoaded) {
            final user = state.receiver;
            return Row(
              children: [
                const CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage('assets/person_marker.png')),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullname,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.status.toLowerCase() == 'active'
                            ? 'Active now'
                            : 'Offline',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Text('Chat', style: TextStyle(color: Colors.white));
        },
      ),
      backgroundColor: const Color(0xFF0088CC),
      elevation: 0,
      actions: const [
        IconButton(
            icon: Icon(Icons.call, color: Colors.white), onPressed: null),
        IconButton(
            icon: Icon(Icons.videocam, color: Colors.white), onPressed: null),
      ],
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return BlocBuilder<ChatScreenBloc, ChatScreenState>(
      buildWhen: (previous, current) =>
          previous is! ChatLoaded ||
          current is! ChatLoaded ||
          previous.messages != current.messages,
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ChatError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is ChatLoaded) {
          final messages = state.messages;
          if (messages.isEmpty) {
            return const Center(child: Text('Start a conversation!'));
          }
          return ListView.builder(
            controller: _scrollController,
            reverse: true,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: messages.length,
            itemBuilder: (context, index) => _MessageBubble(
              message: messages[index],
              isSender: messages[index].senderId ==
                  context.read<ChatScreenBloc>().senderId,
            ),
          );
        }
        return const Center(child: Text('Start a conversation!'));
      },
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(0, -1),
              blurRadius: 4)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon:
                const Icon(Icons.add_circle_outline, color: Color(0xFF0088CC)),
            onPressed: () => _showAttachmentOptions(context),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _sendMessage(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF0088CC),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(context),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    if (_messageController.text.isNotEmpty) {
      context.read<ChatScreenBloc>().add(SendMessage(_messageController.text));
      _messageController.clear();
      _scrollToBottom();
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isSender;

  const _MessageBubble({required this.message, required this.isSender});

  @override
  Widget build(BuildContext context) {
    final time = message.sentAt;
    final isImage = message.content.startsWith('http');
    const status = 'sent'; // Simplified for this example

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage('assets/person_marker.png')),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSender ? const Color(0xFF0088CC) : Colors.grey.shade200,
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
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50),
                    )
                  else
                    Text(
                      message.content,
                      style: TextStyle(
                          color: isSender ? Colors.white : Colors.black87,
                          fontSize: 16),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                            color: isSender
                                ? Colors.white70
                                : Colors.grey.shade600,
                            fontSize: 12),
                      ),
                      if (isSender) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.check,
                          size: 16,
                          color: message.isRead ? Colors.green : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isSender)
            const Padding(
                padding: EdgeInsets.only(left: 8), child: SizedBox(width: 16)),
        ],
      ),
    );
  }
}
