import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:gis_osm/common/user_storage.dart';
import '../../data/models/message.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../services/message_service.dart';
import '../distance_tracker_screen.dart';
import '../user_list_screen.dart';
import '../auth_screen.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../widgets/app_bar_action_name.dart';
import '../sidebar.dart';
import 'chat_screen.dart';

class ChatBoxScreen extends StatefulWidget {
  const ChatBoxScreen({super.key});

  @override
  State<ChatBoxScreen> createState() => _ChatBoxScreenState();
}

class _ChatBoxScreenState extends State<ChatBoxScreen> {
  final MessageService _messageService = MessageService();
  final AuthRepository _authRepository = AuthRepository();
  String _selectedFilter = 'All'; // Default filter is 'All'

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: _buildAppBar(context, size),
      drawer: _buildSidebar(context),
      body: Column(
        children: [
          _buildTabSection(size, isSmallScreen),
          Expanded(child: _buildMessageList(size, isSmallScreen)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Size size) {
    return AppBar(
      title: Text(
        'Messages',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: size.width * 0.045,
        ),
      ),
      actions: [
        AppBarActionName(fontSize: size.width * 0.035),
      ],
      centerTitle: true,
      backgroundColor: Colors.lightBlueAccent,
      elevation: 1,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Sidebar(
      onHomeTap: () => _navigate(context, DistanceTrackerScreen()),
      onUsersTap: () => _navigate(context, const UserListScreen()),
      onTrackLocationTap: () => _navigate(context, DistanceTrackerScreen()),
      onChatBoxTap: () => _navigate(context, const ChatBoxScreen()),
      onSettingsTap: () => debugPrint("Settings tapped"),
      onLogoutTap: () {
        context.read<AuthBloc>().add(LogoutEvent());
        _navigate(context, AuthScreen());
      },
    );
  }

  Widget _buildTabSection(Size size, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 16),
            _buildFilterChip('All', isActive: _selectedFilter == 'All'),
            const SizedBox(width: 8),
            _buildFilterChip('Unread', isActive: _selectedFilter == 'Unread'),
            const SizedBox(width: 8),
            _buildFilterChip('Groups'),
            const SizedBox(width: 8),
            _buildFilterChip('Favorites'),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false}) {
    return FilterChip(
      label: Text(label),
      selected: isActive,
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.lightBlueAccent,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : Colors.black87,
      ),
      onSelected: (_) {
        setState(() {
          _selectedFilter = label; // Update the selected filter
        });
      },
    );
  }

  Widget _buildMessageList(Size size, bool isSmallScreen) {
    return FutureBuilder<int?>(
      future: UserStorage.getUserId(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userSnapshot.hasError || userSnapshot.data == null) {
          return Center(child: Text('Error fetching user ID'));
        }

        final int currentUserId = userSnapshot.data!;
        return StreamBuilder<Map<int, List<Message>>>(
          stream: _messageService.getAllMessages(currentUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Center(child: Text('No messages yet.'));
            }

            final groupedMessages = snapshot.data!;
            // Filter messages based on _selectedFilter
            final filteredGroupedMessages = _selectedFilter == 'Unread'
                ? (Map<int, List<Message>>.from(groupedMessages)
                  ..removeWhere((key, messages) =>
                      messages.every((m) => m.isRead != false)))
                : groupedMessages;

            if (filteredGroupedMessages.isEmpty) {
              return const Center(
                  child: Text('No unread messages.',
                      style: TextStyle(color: Colors.grey)));
            }

            return ListView.builder(
              itemCount: filteredGroupedMessages.length,
              itemBuilder: (context, index) {
                final receiverId =
                    filteredGroupedMessages.keys.elementAt(index);
                final messages = filteredGroupedMessages[receiverId]!;
                final latestMessage = messages.first;

                return FutureBuilder<User>(
                  future: _authRepository.getUser(receiverId),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildLoadingTile();
                    }
                    if (userSnapshot.hasError || !userSnapshot.hasData) {
                      return _buildErrorTile();
                    }

                    final user = userSnapshot.data!;
                    return _buildMessageTile(
                        user, latestMessage, currentUserId);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingTile() {
    return const ListTile(
      leading: CircleAvatar(child: Icon(Icons.person)),
      title: Text('Loading...'),
      subtitle: Text('Fetching user info'),
    );
  }

  Widget _buildErrorTile() {
    return const ListTile(
      leading: CircleAvatar(child: Icon(Icons.error)),
      title: Text('Unknown User'),
      subtitle: Text('Failed to load user'),
    );
  }

  Widget _buildMessageTile(
      User user, Message latestMessage, int currentUserId) {
    final isUnread = latestMessage.isRead == false; // Check if unread

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.lightBlueAccent,
        child: Text(user.fullname[0].toUpperCase()), // First letter as avatar
      ),
      title: Text(
        user.fullname,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        latestMessage.content,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey[700],
          fontWeight:
              isUnread ? FontWeight.bold : FontWeight.normal, // Bold if unread
        ),
      ),
      trailing: Text(
        _formatTimestamp(latestMessage.sentAt),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            senderId: currentUserId,
            receiverId: user.id ?? 0,
            route: 1,
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
