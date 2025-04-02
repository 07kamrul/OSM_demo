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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: _buildAppBar(context, size),
      drawer: _buildSidebar(context),
      body: Column(
        children: [
          _buildTabSection(context, size, isSmallScreen),
          Expanded(child: _buildMessageList(context, size, isSmallScreen)),
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

  Widget _buildTabSection(BuildContext context, Size size, bool isSmallScreen) {
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
            _buildFilterChip('All', isActive: true),
            const SizedBox(width: 8),
            _buildFilterChip('Unread'),
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
      onSelected: (_) {},
    );
  }

  Widget _buildMessageList(
      BuildContext context, Size size, bool isSmallScreen) {
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
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No messages yet.'));
            }

            final groupedMessages = snapshot.data!;
            return ListView(
              children: groupedMessages.entries.map((entry) {
                final receiverId = entry.key;
                final messages = entry.value;
                final latestMessage = messages.first; // Show latest message

                return FutureBuilder<User>(
                  future:
                      _authRepository.getUser(receiverId), // Fetch user details
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const ListTile(
                        title: Text('Loading...'),
                        subtitle: Text('Fetching user info'),
                      );
                    }
                    if (userSnapshot.hasError || !userSnapshot.hasData) {
                      return const ListTile(
                        title: Text('Unknown User'),
                        subtitle: Text('Failed to load user'),
                      );
                    }

                    final user = userSnapshot.data!;
                    return ListTile(
                      title: Text(
                          user.fullname), // Now it's safe to access fullName
                      subtitle: Text(latestMessage.content),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            senderId: currentUserId,
                            receiverId: user.id ?? 0,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, Size size) {
    return Center(
      child: Text('No messages yet'),
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
