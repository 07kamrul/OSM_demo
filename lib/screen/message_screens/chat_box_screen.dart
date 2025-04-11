import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/chat_box_screen/chat_box_bloc.dart';
import '../../data/models/message.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../services/message_service.dart';
import '../distance_tracker_screen.dart';
import '../user_list_screen.dart';
import '../auth_screen.dart';
import '../../widgets/app_bar_action_name.dart';
import '../sidebar.dart';
import 'chat_screen.dart';

class ChatBoxScreen extends StatelessWidget {
  const ChatBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatBoxBloc(MessageService(), AuthRepository())..add(LoadChatBox()),
      child: _ChatBoxView(),
    );
  }
}

class _ChatBoxView extends StatelessWidget {
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
            _buildFilterChip(context, 'All'),
            const SizedBox(width: 8),
            _buildFilterChip(context, 'Unread'),
            const SizedBox(width: 8),
            _buildFilterChip(context, 'Groups'),
            const SizedBox(width: 8),
            _buildFilterChip(context, 'Favorites'),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    return BlocBuilder<ChatBoxBloc, ChatBoxState>(
      builder: (context, state) {
        final isActive = state is ChatBoxLoaded && state.filter == label;
        return FilterChip(
          label: Text(label),
          selected: isActive,
          backgroundColor: Colors.grey[200],
          selectedColor: Colors.lightBlueAccent,
          labelStyle: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
          ),
          onSelected: (_) {
            context.read<ChatBoxBloc>().add(ChangeFilter(label));
          },
        );
      },
    );
  }

  Widget _buildMessageList(
      BuildContext context, Size size, bool isSmallScreen) {
    return BlocBuilder<ChatBoxBloc, ChatBoxState>(
      builder: (context, state) {
        if (state is ChatBoxLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ChatBoxError) {
          return Center(child: Text(state.message));
        }
        if (state is ChatBoxLoaded) {
          final filteredGroupedMessages = state.filteredGroupedMessages;
          if (filteredGroupedMessages.isEmpty) {
            return const Center(
                child: Text('No messages yet.',
                    style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            itemCount: filteredGroupedMessages.length,
            itemBuilder: (context, index) {
              final receiverId = filteredGroupedMessages.keys.elementAt(index);
              final userMessages = filteredGroupedMessages[receiverId]!;
              final latestMessage = userMessages.messages.first;

              return _buildMessageTile(context, userMessages.user,
                  latestMessage, state.currentUserId);
            },
          );
        }
        return const Center(child: Text('Start a conversation!'));
      },
    );
  }

  Widget _buildMessageTile(BuildContext context, User user,
      Message latestMessage, int currentUserId) {
    final isUnread = !latestMessage.isRead;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.lightBlueAccent,
        child: Text(user.fullname[0].toUpperCase()),
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
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
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
