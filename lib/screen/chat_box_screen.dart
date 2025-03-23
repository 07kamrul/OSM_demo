import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For timestamp formatting
import '../data/models/message.dart';
import '../screen/distance_tracker_page.dart'; // Assuming this is your Home screen
import '../screen/user_list_screen.dart'; // Assuming this is your User screen
import '../screen/auth_screen.dart'; // For logout navigation
import '../bloc/auth/auth_bloc.dart'; // For logout event
import '../bloc/auth/auth_event.dart';
import '../widgets/app_bar_action_name.dart';
import '../screen/sidebar.dart'; // Sidebar import

class ChatBoxScreen extends StatelessWidget {
  final List<Message> messages;

  const ChatBoxScreen({super.key, this.messages = const []});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600; // Define small screen threshold

    return Scaffold(
      appBar: _buildAppBar(context, size),
      drawer: _buildSidebar(context), // Add sidebar here
      body: Column(
        children: [
          _buildTabSection(context, size, isSmallScreen),
          _buildMessageList(context, size, isSmallScreen),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Size size) {
    final fontSize = size.width * 0.04;

    return AppBar(
      title: Text(
        'Messaging',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
      ),
      actions: [
        AppBarActionName(fontSize: fontSize * 0.8),
      ],
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: size.width * 0.05,
        fontWeight: FontWeight.bold,
      ),
      elevation: 2,
      backgroundColor: Colors.lightBlueAccent,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Sidebar(
      onHomeTap: () => _navigate(context, const DistanceTrackerPage()),
      onUsersTap: () => _navigate(context, const UserListScreen()),
      onTrackLocationTap: () => _navigate(context, const DistanceTrackerPage()),
      onChatBoxTap: () => _navigate(context, const ChatBoxScreen()),
      onSettingsTap: () => debugPrint("Settings tapped"), // Placeholder
      onLogoutTap: () {
        context.read<AuthBloc>().add(LogoutEvent());
        _navigate(context, AuthScreen());
      },
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _buildTabSection(BuildContext context, Size size, bool isSmallScreen) {
    final chipPadding = size.width * 0.02;
    final chipFontSize = isSmallScreen ? 12.0 : 14.0;

    return Padding(
      padding: EdgeInsets.all(chipPadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildChip(
              label: 'Focused',
              color: Colors.green,
              fontSize: chipFontSize,
              padding: chipPadding,
            ),
            SizedBox(width: chipPadding),
            _buildChip(
              label: 'Unread',
              color: Colors.blue,
              fontSize: chipFontSize,
              padding: chipPadding,
            ),
            SizedBox(width: chipPadding),
            _buildChip(
              label: 'My Contacts',
              color: Colors.grey,
              fontSize: chipFontSize,
              padding: chipPadding,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
    required double fontSize,
    required double padding,
  }) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
      onPressed: () {},
    );
  }

  Widget _buildMessageList(
      BuildContext context, Size size, bool isSmallScreen) {
    return Expanded(
      child: messages.isEmpty
          ? _buildEmptyState(context, size)
          : ListView.builder(
              itemCount: messages.length,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageTile(context, message, size, isSmallScreen);
              },
            ),
    );
  }

  Widget _buildMessageTile(
    BuildContext context,
    Message message,
    Size size,
    bool isSmallScreen,
  ) {
    final avatarSize = size.width * (isSmallScreen ? 0.1 : 0.08);
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final timestampFontSize = isSmallScreen ? 10.0 : 12.0;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.005,
      ),
      leading: CircleAvatar(
        radius: avatarSize / 2,
        backgroundImage: const NetworkImage('https://i.pravatar.cc/150'),
        onBackgroundImageError: (_, __) => const Icon(Icons.person),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              message.senderId,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTimestamp(message.sentAt),
            style: TextStyle(
              fontSize: timestampFontSize,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      subtitle: Text(
        message.content,
        style: TextStyle(fontSize: fontSize * 0.9),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        message.isRead ? Icons.check_circle : Icons.check_circle_outline,
        color: message.isRead ? Colors.green : Colors.grey,
        size: size.width * 0.06,
      ),
      onTap: () {
        // Navigate to chat details or mark as read
      },
      tileColor: message.isRead ? null : Colors.grey[100],
    );
  }

  Widget _buildEmptyState(BuildContext context, Size size) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: size.width * 0.15,
            color: Colors.grey,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: size.width * 0.05,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM d').format(dateTime);
    } else {
      return DateFormat('HH:mm').format(dateTime);
    }
  }
}
